- [Creating a JupyterHub on Jetstream with the Zero to JupyterHub Project](#h-D73CBC56)
  - [Kubernetes Cluster](#h-65F9358E)
    - [jupyterhub.sh](#h-B56E19AB)
    - [Create Cluster](#h-2FF65549)
  - [Docker Image for JupyterHub User Environment](#h-CD007D2A)
  - [Configure and Deploy the JupyterHub](#h-E5CA5D99)
    - [SSL Certificates](#h-294A4A20)
    - [OAuth Authentication](#h-8A3C5434)
    - [Docker Image and Other Configuration](#h-214D1D4C)
    - [JupyterHub Profiles](#h-5BE09B80)
    - [Create a Large Data Directory That Can Be Shared Among All Users](#h-C95C198A)
  - [Navigate to JupyterHub](#h-209E2FBC)
  - [Tearing Down JupyterHub](#h-1E027567)
    - [Total Destructive Tear Down](#h-A69ADD92)
    - [Tear Down While Preserving User Volumes](#h-5F2AA05F)
  - [Troubleshooting](#h-0E48EFE9)
    - [Unresponsive JupyterHub](#h-FF4348F8)
    - [Volumes Stuck in Reserved State](#h-354DE174)
    - [Renew Expired K8s Certificates](#h-60D08FB6)
    - [Evicted Pods Due to Node Pressure](#h-93b43b3e)


<a id="h-D73CBC56"></a>

# Creating a JupyterHub on Jetstream with the Zero to JupyterHub Project


<a id="h-65F9358E"></a>

## Kubernetes Cluster


<a id="h-B56E19AB"></a>

### jupyterhub.sh

`jupyterhub.sh` and the related `z2j.sh` are convenience scripts similar to `openstack.sh` to give you access to a pre-configured environment that will allow you to build and/or run a Zero to JupyterHub cluster. It also relies on the [same Docker container](../../openstack/readme.md) as the `openstack.sh` script. `jupyterhub.sh` takes the following required arguments:

```shell
-n, --name JupyterHub name
-p, --ip JupyterHub IP
-o, --openrc openrc.sh absolute path
```

*Important*: The `--name` argument is used to set the names of the instances (VMs) of the cluster, which in turn is used to define the DNS name of assigned to the floating IP of the master node ([see here](../../vms/openstack/readme.md)). Ensure that the name provided to `jupyterhub.sh` results in a domain name that is less than 64 characters long, else LetsEncrypt will not be able to issue a certificate ([see here](https://letsencrypt.org/docs/glossary/#def-CN)).

Invoke `jupyterhub.sh` from the `science-gateway/openstack` directory. `jupyterhub.sh` and the related `z2j.sh` ensure the information for this Zero to JupyterHub cluster is persisted outside the container via Docker file mounts &#x2013; otherwise all the information about this cluster would be confined in memory inside the Docker container. The vital information will be persisted in a local `jhub` directory.


<a id="h-2FF65549"></a>

### Create Cluster

[Create a Kubernetes cluster](../../openstack/readme.md) with the desired number of nodes and VM sizes. Lock down the master node of the cluster per Unidata security procedures. Work with sys admin staff to obtain a DNS name (e.g., jupyterhub.unidata.ucar.edu), and a certificate from a certificate authority for the master node. Alternatively, you can use JetStream2's [dynamic DNS](../../openstack/readme.md#dynamicdns) and acquire a self signed certificate with [LetsEncrypt](#h-294A4A20).


<a id="h-CD007D2A"></a>

## Docker Image for JupyterHub User Environment

Build the Docker container that will be employed by the user environment on their JupyterHub instance. This Docker image will be [referenced in the secrets.yaml](#h-214D1D4C). Uniquely tag the image with a date and ID for sane retrieval and referencing. For example:

```sh
docker build -t unidata/unidatahub:`date +%Y%b%d_%H%M%S`_`openssl rand -hex 4` . > /tmp/docker.out 2>&1 &
docker push unidata/unidatahub:<container id>
```


<a id="h-E5CA5D99"></a>

## Configure and Deploy the JupyterHub

From the client host where you created the Kubernetes cluster, follow [Andrea Zonca's instructions](https://zonca.dev/2020/06/kubernetes-jetstream-kubespray.html#install-jupyterhub).

After you have created the `secrets.yaml` as instructed, customize it with the choices below


<a id="h-294A4A20"></a>

### SSL Certificates

1.  Letsencrypt

    Follow [Andrea's instructions](https://www.zonca.dev/posts/2020-03-13-setup-https-kubernetes-letsencrypt.html) on setting up letsencrypt using [cert-manager](https://cert-manager.io/). Due to a [network change between JS1 and JS2](https://docs.jetstream-cloud.org/faq/trouble/#i-cant-ping-or-reach-a-publicfloating-ip-from-an-internal-non-routed-host), the cert-manager pods must be run on the k8s master node in order to successfully complete the [challenges](https://letsencrypt.org/how-it-works/) required by letsencrypt to issue the certificate. Pay special attention to the [Bind the pods to the master node](https://www.zonca.dev/posts/2020-03-13-setup-https-kubernetes-letsencrypt.html#bind-the-pods-to-the-master-node) section.

    For further reading:

    -   [Assigning a pod to a specific node](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-your-chosen-node)
    -   [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

2.  Certificate from Certificate Authority

    Work with Unidata system administrator staff to obtain a certificate from a trusted certificate authority.

    Follow [Andrea's instructions](https://www.zonca.dev/posts/2018-09-24-jetstream_kubernetes_kubespray_jupyterhub#setup-https-with-custom-certificates) on setting up HTTPS with custom certificates. Note that when adding the key with

    ```shell
    kubectl create secret tls <cert-secret> --key ssl.key --cert ssl.crt -n jhub
    ```

    supply the base and intermediate certificates and not the full chain certificate (i.e., with root certificates). You can find these certificates [here](https://uit.stanford.edu/service/ssl/chain).

    Here is a snippet of what the ingress configuration will look like in the `secrets.yaml`.

    ```yaml
    ingress:
      enabled: true
      annotations:
        cert-manager.io/issuer: "incommon"
      hosts:
          - <jupyterhub-host>
      tls:
          - hosts:
             - <jupyterhub-host>
            secretName: <secret_name>
    ```

    1.  Certificate Expiration and Renewal

        When these certificates expire, they can be updated with the snippet below, but **be careful** to update the certificate on the correct JupyterHub deployment. Otherwise, you will be in cert-manger hell.

        ```shell
        kubectl create secret tls cert-secret --key ssl.key --cert ssl.crt -n jhub \
            --dry-run=client -o yaml | kubectl apply -f -
        ```


<a id="h-8A3C5434"></a>

### OAuth Authentication

1.  Globus

    [Globus OAuth capability](https://developers.globus.org/) is available for user authentication. The instructions [here](https://oauthenticator.readthedocs.io/en/latest/reference/api/gen/oauthenticator.globus.html) are relatively straightforward.

    ```yaml
    auth:
      type: globus
      globus:
        clientId: "xxx"
        clientSecret: "xxx"
        callbackUrl: "https://<jupyterhub-host>:443/oauth_callback"
        identityProvider: "xsede.org"
      admin:
        users:
          - adminuser1
    ```

2.  GitHub

    Setup an OAuth app on GitHub

    ```yaml
    auth:
      type: github
      github:
        clientId: "xxx"
        clientSecret: "xxx"
        callbackUrl: "https://<jupyterhub-host>:443/oauth_callback"
      admin:
        users:
          - adminuser1
    ```


<a id="h-214D1D4C"></a>

### Docker Image and Other Configuration

Reference [the previously built Docker image](#h-CD007D2A) (e.g., `unidata/unidatahub:2022Dec15_031132_fe2ea584`). Customize the desired CPU / RAM usage. [This spreadsheet](https://docs.google.com/spreadsheets/d/15qngBz4L5gwv_JX9HlHsD4iT25Odam09qG3JzNNbdl8/edit?usp=sharing) will help you determine the size of the cluster based on number of users, desired cpu/user, desired RAM/user. Duplicate it and adjust it for your purposes.

```yaml
singleuser:
  extraEnv:
    NBGITPULLER_DEPTH: "0"
  storage:
    capacity: 3Gi
  startTimeout: 600
  memory:
    guarantee: 4G
    limit: 4G
  cpu:
    guarantee: 1
    limit: 2
  defaultUrl: "/lab"
  image:
    name: unidata/unidatahub
    tag: 2022Dec15_031132_fe2ea584
  lifecycleHooks:
    postStart:
      exec:
          command:
            - "sh"
            - "-c"
            - >
              gitpuller https://github.com/Unidata/python-training main python-training;
              cp /README_FIRST.ipynb /home/jovyan;
              cp /Acknowledgements.ipynb /home/jovyan;
              cp /.condarc /home/jovyan
```


<a id="h-5BE09B80"></a>

### JupyterHub Profiles

A JupyterHub may be configured to give users different [profile options](https://z2jh.jupyter.org/en/stable/jupyterhub/customizing/user-environment.html#using-multiple-profiles-to-let-users-select-their-environment) when logging in. This can be useful when, for example, a faculty member is using JupyterHub for multiple courses and wants to keep them seperate. Another use case is for creating "high power" or "low power" environments, which are allocated varying levels of computational resources, i.e. RAM and CPU. This can be applied in an undergraduate research setting where an instructor and their students use the low power environments during synchronous instruction and the high power environment for asynchronous workflows.

An example of high and low power environments is shown below.

```yaml
singleuser:
  # Set defaults and options shared by all profiles
  extraEnv:
    NBGITPULLER_DEPTH: "0"
  storage:
    capacity: 5Gi
  startTimeout: 600
  image:
    name: "unidata/someImage"
    tag: "someTag"
  # Profile definitions
  profileList:
    - display_name: "High Power (default)"
      description: "12 GB of memory; up to 4 vCPUs"
      kubespawner_override:
        mem_guarantee: 12G
        mem_limit: 12G
        cpu_guarantee: 2
        cpu_limit: 4
      default: true
    - display_name: "Low Power"
      description: "6 GB of memory; up to 2 vCPUS"
      kubespawner_override:
        mem_guarantee: 6G
        mem_limit: 6G
        cpu_guarantee: 1
        cpu_limit: 2
```

Note, however, that while one would typically provide `secrets.yaml` with the CPU and memory guarantees/limits as shown below, when using the `kubespawner_override` object to set these options for various profiles, you must provide the names of the fields as Kubespawner will recognize them.

```yaml
# Typical manner of configuring CPU and memory options
singleuser:
  memory:
    guarantee: 4G
    limit: 4G
  cpu:
    guarantee: 1
    limit: 2

# Kubespawner override
singleuser:
  profileList:
    - kubespawner_override:
      mem_guarantee: 16G
      mem_limit: 16G
      cpu_guarantee: 4
      cpu_limit: 4
```

See [this](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/1242#issuecomment-484895216) GitHub issue for a description of the discrepancy, and the [Kubespawner docs](https://jupyterhub-kubespawner.readthedocs.io/en/latest/spawner.html) for the appropriate names to use for the various options when creating profiles.


<a id="h-C95C198A"></a>

### Create a Large Data Directory That Can Be Shared Among All Users

[Andrea has a tutorial about sharing a directory](https://www.zonca.dev/posts/2023-02-06-nfs-server-kubernetes-jetstream) (e.g., `/share/data`) via Kubernetes and NFS. The instructions basically work as advertised with the KubeSpray option (not Magnum &#x2013; I have not tried that), e.g.,

```yaml
nfs:
    # for Magnum
    # server: 10.254.204.67
    # for Kubespray
    server: 10.233.46.63
    path: /
```

The `clusterIP` is arbitrary and the one in the `jupyterhub-deploy-kubernetes-jetstream/nfs/` directory works. That IP is referenced in multiple locations in that directory. Make sure you get them all.

Define the size of the shared volume in `create_nfs_volume.yaml`, e.g.,:

```yaml
resources:
  requests:
    storage: 300Gi
```

Verify `nfs-common` is installed on the worker nodes (more recent versions of AZ's `jetstream_kubespray` project will have this already so you won't have to manually install the package), e.g.,

```sh
sudo apt install -y nfs-common
```


<a id="h-209E2FBC"></a>

## Navigate to JupyterHub

In a web browser, navigate to your newly minted JupyterHub and see if it is as you expect.


<a id="h-1E027567"></a>

## Tearing Down JupyterHub


<a id="h-A69ADD92"></a>

### Total Destructive Tear Down

Tearing down the JupyterHub including user OpenStack volumes is possible. From the Helm and Kubernetes client:

```sh
helm uninstall jhub -n jhub
# Think before you type !
echo $CLUSTER; sleep 60; kubectl delete namespace jhub
```

To further tear down the Kubernetes cluster see [Tearing Down the Cluster](../../openstack/readme.md).


<a id="h-5F2AA05F"></a>

### Tear Down While Preserving User Volumes

A gentler tear down that preserves the user volumes is described in [Andrea's documentation](https://www.zonca.dev/posts/2018-09-24-jetstream_kubernetes_kubespray_jupyterhub). See the section on "persistence of user data".


<a id="h-0E48EFE9"></a>

## Troubleshooting


<a id="h-FF4348F8"></a>

### Unresponsive JupyterHub

1.  Preliminary Work

    If a JupyterHub becomes unresponsive (e.g., 504 Gateway Time-out), login in to the Kubernetes client and do preliminary backup work in case things go badly. First:

    ```shell
    kubectl get pvc -n jhub -o yaml > pvc.yaml.ro
    kubectl get pv -n jhub -o yaml > pv.yaml.ro
    chmod 400 pvc.yaml.ro pv.yaml.ro
    ```

    Make `pvc.yaml.ro` `pv.yaml.ro` read only since these files could become precious in case you have to do data recovery for users. More on this subject below.

2.  Delete jhub Pods

    Next, start investigating by issuing:

    ```shell
    kubectl get pods -n jhub
    ```

    this command will yield something like

    ```shell
    NAME                      READY   STATUS    RESTARTS   AGE
    hub-5bdccd4784-lzw87      1/1     Running   0          17h
    jupyter-joe               1/1     Running   0          4h51m
    proxy-7b986cdb75-mhl86    1/1     Running   0          29d
    ```

    Now start deleting the `jhub` pods starting with the user pods (e.g., `jupyter-joe`).

    ```
    kubectl delete pod <pod name> -n jhub
    ```

    Check to see if the JupyterHub is reachable. If it is not, keep deleting pods checking for reachability after each pod deletion.

3.  Delete jhub, But Do Not Purge Namespace

    If the JupyterHub is still not reachable, you can try deleting and recreating the JupyterHub but **do not** delete the namespace as you will wipe out user data.

    ```shell
    helm uninstall jhub -n jhub
    # But DO NOT issue this command
    # kubectl delete namespace jhub
    ```

    Then try reinstalling with

    ```
    bash install_jhub.sh
    ```

    Now, try recover user volumes as [described at the end of the section here](https://zonca.dev/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html#delete-and-recreate-openstack-instances) with the `pvc.yaml.ro` `pv.yaml.ro` saved earlier (make writable copies of those `ro` files). If that still does not work, you can try destroying the entire cluster and recreating it as described in that same link.


<a id="h-354DE174"></a>

### Volumes Stuck in Reserved State

1.  Background

    Occasionally, when logging into a JupyterHub the user will encounter a volume attachment error that causes a failure in the login process. [This is an ongoing issue on Jetstream that we have never been able to get to the bottom of](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/issues/40). The user will see an error that looks something like:

    ```shell
    2020-03-27 17:54:51+00:00 [Warning] AttachVolume.Attach failed for volume "pvc-5ce953e4-6ad9-11ea-a62a-fa163ebb95dd" : Volume "0349603a-967b-44e2-98d1-0ba1d42c37d8" is attaching, can't finish within the alloted time
    ```

    When you then do an `openstack volume list`, you will see something like this where a volume is stuck in "reserved":

    ```shell
    |--------------------------------------+------------------------------------------+----------|
    | ID                                   | Name                                     | Status   |
    |--------------------------------------+------------------------------------------+----------|
    | 25c25c5d-75cb-48fd-a9c4-4fd680bea79b | pvc-41d76080-6ad7-11ea-a62a-fa163ebb95dd | reserved |
    |--------------------------------------+------------------------------------------+----------|
    ```

    You (or if you do not have permission, Jetstream staff) can reset the volume with:

    ```shell
    openstack volume set --state available <volume uuid>
    ```

    or with

    ```shell
    openstack volume list | grep -i reserved | awk \
        'BEGIN { FS = "|" } ; { print $2 }' | xargs -n1 openstack volume set \
    --state available
    ```

    The problem is that once a volume gets stuck like this, it tends to happen again and again. In this scenario, [you have to provide a long term solution to the user](#h-CB601D7B).

2.  Script to Mitigate Problem

    Invoking this script (e.g., call it `notify.sh`) from crontab, maybe every three minutes or so, can help mitigate the problem and give you faster notification of the issue. Note [iftt](https://ifttt.com) is a push notification service with webhooks available that can notify your smart phone triggered by a `curl` invocation as demonstrated below. You'll have to create an ifttt login and download the app on your smart phone.

    ```shell
    #!/bin/bash

    source /home/rocky/.bash_profile

    VAR=$(openstack volume list -f value -c ID -c Status | grep -i reserved | wc -l)

    MSG="Subject: Volume Stuck in Reserved on Jetstream"

    if [[ $VAR -gt 0 ]]
    then
        echo $MSG | /usr/sbin/sendmail my@email.com
        openstack volume list | grep -i reserved >> /tmp/stuck.txt
        curl -X POST https://maker.ifttt.com/trigger/jetstream/with/key/xyz
        openstack volume list -f value -c ID -c Status | grep -i reserved | awk \
            '{ print $1 }' | xargs -n1 openstack volume set --state available
    fi
    ```

    you can invoke this script from crontab:

    ```shell
    */3 * * * * /home/rocky/notify.bash > /dev/null 2>&1
    ```

    Note, again, this is just a temporary solution. You still have to provide a longer-term workaround described in the next section:

3.  Not a Solution but a Longer Term Workaround

    [With the volume ID obtained earlier](#h-1765D7EB), issue:

    ```shell
    openstack volume attachment list --os-volume-api-version 3.27 | grep -i d910c7fae38b
    ```

    which will yield something like:

    ```shell
    | 67dbf5c3-c190-4f9e-a2c9-78da44df6c75 | cf1a7adf-7b0a-422f-8843-d910c7fae38b | reserved  | 0593faaf-8ba0-4eb5-84ad-b7282ce5aac2 |
    ```

    At this point, you may see *two* entries (even though only one is shown here). One attachment in reserved and one that is attached.

    Next, delete the reserved attachment:

    ```shell
    cinder attachment-delete 67dbf5c3-c190-4f9e-a2c9-78da44df6c75
    ```


<a id="h-60D08FB6"></a>

### Renew Expired K8s Certificates

1.  Background

    Kubernetes clusters use PKI certificates to allow the different components of K8s to communicate and authenticate with one another. See the [official docs](https://kubernetes.io/docs/setup/best-practices/certificates/) for more information. When firing up a JupyterHub cluster using the procedures outlined in this documentation, the certificates are automatically generated for us on cluster creation, however they expire after a full year. You can check the expiration date of your current certificates by running the following on the master node of the cluster:

    ```shell
    sudo kubeadm alpha certs check-expiration
    ```

    Once the certificates have expired, you will be unable to run, for example, `kubectl` commands, and the [control plane components](https://kubernetes.io/docs/setup/best-practices/certificates/) will not be able to, for example, fire up new pods, ie new JupyterLab servers, nor perform `helm` upgrades to the server. Example output of running `kubectl` commands with expired certificates is:

    ```shell
    # kubectl get pods -n jhub
    Unable to connect to the server: x509: certificate has expired or is not yet valid: current time 2022-06-29T23:09:31Z is after 2022-06-28T17:38:37Z
    ```

2.  Resolution

    There are a number of ways to renew certificates outlined in the [official docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/). Here, the manual renewal method is outlined. While this procedure should be non-destructive, it is recommended to have users backup data/notebooks before this is done. In addition, one of the steps requires a manual restart of the control plane pods, which means the Hub (and potentially user servers) may suffer a small amount of downtime.

    All commands are ran on the master node of the cluster. In addition, the documentation does not include the `alpha` portion of the `kubeadm` commands outlined below. This is required: see the answer to [this](https://serverfault.com/questions/1051333/how-to-renew-a-certificate-in-kubernetes-1-12) question.

    First, confirm that your certificates truly are expired:

    ```shell
    sudo kubeadm alpha certs check-expiration
    ```

    Then, run the renewal command to renew all certs:

    ```shell
    sudo kubeadm alpha certs renew all
    ```

    Double check the certificates were renewed:

    ```shell
    sudo kubeadm alpha certs check-expiration
    ```

    Now, we must restart the control plane pods. We do this by moving the files found in `/etc/kubernetes/manifests` to a temporary place, waiting for the [kubelet](https://serverfault.com/questions/1051333/how-to-renew-a-certificate-in-kubernetes-1-12) to recognize the change in the manifests, and tear down the pods. Once this is done, the files can be moved back into `/etc/kubernetes/manifests`, and we can wait for the kubelet to respawn the pods. Finally, reset the `~/.kube/config` file and run `kubectl` commands.

    ```shell
    ###
    # All commands ran on the master node
    ###

    # Copy manifests
    mkdir ~/manifestsBackup_yyyy_mm_dd
    sudo cp /etc/kubernetes/manifests/* ~/manifestsBackup_yyyy_mm_dd/

    # Sanity check
    ls ~/manifestsBackup_yyyy_mm_dd

    # Navigate to /etc/kubernetes/manifests and list files, to ensure we're removing
    # what we think we are
    cd /etc/kubernetes/manifests
    ls

    # Verify the containers you are about to remove are currently running
    sudo docker ps

    # Remove files
    rm ./*

    # Wait until the containers are removed
    sudo docker ps

    # Replace files
    sudo cp ~/manifestsBackup_yyyy_mm_dd/* /etc/kubernetes/manifests/

    # Wait until containers are respawned
    sudo docker ps

    # Reset the config
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Cross your fingers and hope you can now run kubectl commands again!
    kubectl get pods --all-namespaces
    ```

    If you want to run kubectl commands from another machine, for example the machine where we launch JupyterHubs from within docker containers, you must copy this config file to that machine's `$HOME/.kube` directory.

    You should have the IP and `ssh` access of/to the master node. Copy over the config through `scp`:

    ```shell
    ###
    # On the appropriate "Jupyter control center" docker container
    ###

    # Directory probably already exists, but try creating the directory anyways
    mkdir $HOME/.kube
    scp ubuntu@<ip>:~/.kube/config $HOME/.kube/config
    ```

    Finally, edit the `server` value in the `$HOME/.kube/config` to point to `127.0.0.1`, as kubectl will communicate with the api-server through a tunnel created on the Jupyter control container. See [this](../../../openstack/bin/kube-setup2.sh) script and the reference therein for the reason behind doing this.

    ```shell
    # Change a line that looks like the following
    server: https://<some-ip>:6443
    # to
    server: https://127.0.0.1:6443
    ```

    You should now be able to run `kubectl` commands, fire up new user servers, and run `helm` upgrades.

<a id="h-93b43b3e"></a>

### Evicted Pods Due to Node Pressure

If a node starts to run out of resources and you try to fire up new pods on it,
the pods will have the "evicted" status associated with them. This can happen
when trying to update a JupyterHub whose single user JupyterLab images are
large, as Jetstream2's `m3.medium` instances only have `60GB` of disk storage.

This problem was first noticed when updating MVU's JupyterHub, whose single user
image was on the order of `10GB`. The new JupyterLab image was going to be
similarly large.

Unless otherwise stated, all output of shell commands are from the `mvu-test`
cluster.

This is what a "healthy" cluster looks like:

```shell
$ kubectl get pods -n jhub
NAME                              READY   STATUS    RESTARTS   AGE
continuous-image-puller-kc4v5     1/1     Running   0          21h
hub-64747d5848-x6z7s              1/1     Running   0          21h
proxy-6675c69dd4-47b4d            1/1     Running   0          10d
user-scheduler-79c85f98dd-r7gl4   1/1     Running   0          10d
user-scheduler-79c85f98dd-vqz24   1/1     Running   0          10d

$ kubectl get nodes -n jhub
NAME                     STATUS   ROLES                  AGE   VERSION
mvu-test-1               Ready    control-plane,master   10d   v1.22.5
mvu-test-k8s-node-nf-1   Ready    <none>                 10d   v1.22.5
```

If we inspect the worker node, we will see the following relevant information:

```shell
$ kubectl describe node -n jhub mvu-test-k8s-node-nf-1 | less
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Mon, 06 Feb 2023 03:39:57 +0000   Mon, 06 Feb 2023 03:39:57 +0000   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Thu, 16 Feb 2023 23:39:42 +0000   Mon, 06 Feb 2023 03:39:25 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Thu, 16 Feb 2023 23:39:42 +0000   Thu, 16 Feb 2023 01:43:51 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Thu, 16 Feb 2023 23:39:42 +0000   Mon, 06 Feb 2023 03:39:25 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Thu, 16 Feb 2023 23:39:42 +0000   Mon, 06 Feb 2023 03:39:59 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
```

The "Conditions" field describes that the node is undergoing no [Node
Pressure](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/).
If the node were experiencing some kind of node pressure, attempting to create
any pods would cause them to become stuck in the "evicted" state. By
[default](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#hard-eviction-thresholds),
pods will be evicted from a node if the available storage space on the node
falls below `10%`.

Attempting to re-deploy the JupyterHub with a new image will cause the
JupyterHub to pull in the new image. If this results in disk pressure, you will
see Kubernetes create pods that receive the "Evicted" state:

```shell
$ bash install_jhub.sh

# In a seperate shell
$ kubectl get pods -n jhub
NAME                              READY   STATUS    RESTARTS   AGE
continuous-image-puller-hm25g     0/1     Evicted   0          36s
hook-image-awaiter--1-4zmsc       0/1     Pending   0          43s
hook-image-puller-f4ffs           0/1     Evicted   0          12s
hub-85c77d5fd-9zhb5               0/1     Pending   0          98s
jupyter-robertej09                1/1     Running   0          19m
proxy-6675c69dd4-47b4d            1/1     Running   0          10d
user-scheduler-79c85f98dd-r7gl4   1/1     Running   0          10d
user-scheduler-79c85f98dd-vqz24   1/1     Running   0          10d
```

The node will show that it is indeed experiencing disk pressure:

```shell
$ kubectl describe node -n jhub <node-name> | less # and scroll down
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Mon, 06 Feb 2023 03:39:57 +0000   Mon, 06 Feb 2023 03:39:57 +0000   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Fri, 17 Feb 2023 00:48:47 +0000   Mon, 06 Feb 2023 03:39:25 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         True    Fri, 17 Feb 2023 00:48:47 +0000   Fri, 17 Feb 2023 00:45:37 +0000   KubeletHasDiskPressure       kubelet has disk pressure
  PIDPressure          False   Fri, 17 Feb 2023 00:48:47 +0000   Mon, 06 Feb 2023 03:39:25 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Fri, 17 Feb 2023 00:48:47 +0000   Mon, 06 Feb 2023 03:39:59 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
```

Scrolling to the "Events" section of the `describe node` output, you may find
that Kubernetes is attempting to salvage the install by freeing up storage
space. This particular output was created while JupyterHub was being upgraded
on the "main" `mvu-23s` cluster:

```shell
Events:
  Type     Reason                 Age                From     Message
  ----     ------                 ----               ----     -------
  Warning  EvictionThresholdMet   55m (x4 over 17d)  kubelet  Attempting to reclaim ephemeral-storage
  Normal   NodeHasDiskPressure    55m (x4 over 17d)  kubelet  Node mvu23s-k8s-node-nf-9 status is now: NodeHasDiskPressure
  Normal   NodeHasNoDiskPressure  50m (x5 over 29d)  kubelet  Node mvu23s-k8s-node-nf-9 status is now: NodeHasNoDiskPressure
```

In this case, Kubernetes successfully performed garbage collection and was able
to recover enough storage space to complete the install after some period of
waiting.

If Kubernetes is taking too long to want to perform garbage collection, there is
a very hacky work-around to this. Cancel the installation (`ctrl-c`), and run
`helm uninstall jhub -n jhub`. This will uninstall the JupyterHub from the
cluster, however, importantly it will [keep user data
intact](https://www.zonca.dev/posts/2018-09-24-jetstream_kubernetes_kubespray_jupyterhub#delete-and-reinstall-jupyterhub). 

Through some inspection, you may find that the worker nodes contain a cache of
not only the single user image which is currently deployed, but the previous one
as well:

```shell
$ kubectl get nodes -o yaml | less # after scrolling down you'll eventually see in the worker node
    images:
    - names:
      - docker.io/unidata/mvu-spring-2023@sha256:a092260d963474b04b71f9b2887faaa879ed0e61d3b2867972308e962b41d7dc
      - docker.io/unidata/mvu-spring-2023:2023Feb16_001123_74af5561
      sizeBytes: 2656565418
    - names:
      - docker.io/unidata/mvu-spring-2023@sha256:2a257f0673482a110dd73b42f91854ecc2d7a3244aa7fd34c988b2fb591d4335
      - docker.io/unidata/mvu-spring-2023:2023Feb04_021143_912787ce
      sizeBytes: 2653100806
```

The work-around is to force the removal of one of the images by installing a
small single user image in the JupyterHub that you know will fit on the node's
available storage space. The
[jupyter/base-notebook](https://hub.docker.com/r/jupyter/base-notebook/tags)
image is a good candidate for this. Edit the appropriate sections of
`secrets.yaml` to install this smaller image, run `bash install_jhub.sh`, and
watch `kubectl get pods -n jhub` to ensure everything installs correctly.
Kubernetes should have purged one of the previous images and freed up storage
space. Now, re-edit `secrets.yaml` and install the image you desire.
