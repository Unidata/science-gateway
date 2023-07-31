- [Creating a JupyterHub on Jetstream with the Zero to JupyterHub Project](#h-D73CBC56)
  - [Kubernetes Cluster](#h-65F9358E)
    - [jupyterhub.sh](#h-B56E19AB)
    - [Create Cluster](#h-2FF65549)
  - [Docker Image for JupyterHub User Environment](#h-CD007D2A)
  - [Configure and Deploy the JupyterHub](#h-E5CA5D99)
    - [SSL Certificates](#h-294A4A20)
      - [Letsencrypt](#h-E1082806)
      - [Certificate from Certificate Authority](#h-205AEDAB)
        - [Certificate Expiration and Renewal](#h-055BCE98)
    - [OAuth Authentication](#h-8A3C5434)
      - [Globus](#h-C0E8193F)
      - [GitHub](#h-BB3C66CD)
    - [Docker Image and Other Configuration](#h-214D1D4C)
    - [JupyterHub Profiles](#h-5BE09B80)
    - [Create a Large Data Directory That Can Be Shared Among All Users](#h-C95C198A)
    - [Ensure "Core" Pods Are Scheduled on a Dedicated Node](#h-6784737C)
    - [Bug Fix: Remove Username Based Labels from Pods and PVCs](#h-1a179c1a)
  - [Navigate to JupyterHub](#h-209E2FBC)
  - [Tearing Down JupyterHub](#h-1E027567)
    - [Total Destructive Tear Down](#h-A69ADD92)
      - [What to Do If Deleting the jhub Namespace Gets Stuck](#h-8CD654F7)
    - [Tear Down While Preserving User Volumes](#h-5F2AA05F)
    - [Locating and Deleting Orphaned PVCs](#h-801B7EE9)
      - [Obtain PVCs That Are in Use](#h-020D86A3)
      - [Obtain All the OpenStack Volumes](#h-0ACAC986)
      - [Find the Orphaned Volumes](#h-ED8A929F)
      - [Delete Orphaned Volumes](#h-D62E010F)
  - [Troubleshooting](#h-0E48EFE9)
    - [Unresponsive JupyterHub](#h-FF4348F8)
      - [Preliminary Work](#h-C2429D6E)
      - [Delete jhub Pods](#h-6404011E)
      - [Delete jhub, But Do Not Purge Namespace](#h-1C4D98E6)
    - [Volumes Stuck in Reserved State](#h-354DE174)
      - [Background](#h-1765D7EB)
      - [Script to Mitigate Problem](#h-F7B1FC52)
      - [Not a Solution but a Longer Term Workaround](#h-CB601D7B)
    - [Renew Expired K8s Certificates](#h-60D08FB6)
      - [Background](#h-01F8D10F)
      - [Resolution](#h-0A5DF245)
    - [Evicted Pods Due to Node Pressure](#h-CEF2540C)
    - [Updating Openstack Credentials for Kubernetes](#h-FABFCED0)
      - [Creating New Credentials](#h-6F9D771F)
      - [Updating Credentials in K8s](#h-4126F02C)
    - [Persistent File/Directory Permissions e.g., ~/.ssh](#h-761EE5B5)
      - [Why This Occurs](#h-7275F48A)
      - [Simple Workaround](#h-FB656610)



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


<a id="h-E1082806"></a>

#### Letsencrypt

Follow [Andrea's instructions](https://www.zonca.dev/posts/2020-03-13-setup-https-kubernetes-letsencrypt.html) on setting up letsencrypt using [cert-manager](https://cert-manager.io/). Due to a [network change between JS1 and JS2](https://docs.jetstream-cloud.org/faq/trouble/#i-cant-ping-or-reach-a-publicfloating-ip-from-an-internal-non-routed-host), the cert-manager pods must be run on the k8s master node in order to successfully complete the [challenges](https://letsencrypt.org/how-it-works/) required by letsencrypt to issue the certificate. Pay special attention to the [Bind the pods to the master node](https://www.zonca.dev/posts/2020-03-13-setup-https-kubernetes-letsencrypt.html#bind-the-pods-to-the-master-node) section.

For further reading:

-   [Assigning a pod to a specific node](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-your-chosen-node)
-   [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)


<a id="h-205AEDAB"></a>

#### Certificate from Certificate Authority

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


<a id="h-055BCE98"></a>

##### Certificate Expiration and Renewal

When these certificates expire, they can be updated with the snippet below, but **be careful** to update the certificate on the correct JupyterHub deployment. Otherwise, you will be in cert-manger hell.

```shell
kubectl create secret tls cert-secret --key ssl.key --cert ssl.crt -n jhub \
    --dry-run=client -o yaml | kubectl apply -f -
```


<a id="h-8A3C5434"></a>

### OAuth Authentication


<a id="h-C0E8193F"></a>

#### Globus

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


<a id="h-BB3C66CD"></a>

#### GitHub

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


<a id="h-6784737C"></a>

### Ensure "Core" Pods Are Scheduled on a Dedicated Node

When a JupyterHub is expected to be used for especially resource intensive tasks, for example running WRF from within JupyterHub, by multiple users simultaneously, their single user pods can use all of a worker node's resources. This is a problem when these worker nodes also contain the JupyterHub's [core pods](https://z2jh.jupyter.org/en/stable/resources/reference.html#scheduling-corepods), which all perform some essential function of a healthy Zero-to-JupyterHub cluster. In particular, it's been observed that if the proxy pod, the component which routes both internal and external requests to the Hub and single user servers, does not have the necessary resources, the JupyterHub will crash.

To prevent this from happening, we can ensure all core pods are scheduled on a dedicated node. This is accomplished by assigning to a chosen node a [taint](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), an attribute which prevents pods from spawning unless they have the corresponding [toleration](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/). This alone is not enough however, as a pod's [node affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/) must require it to spawn on that specific node. The process is described below.

Add the taint to `<node-name>`:

```shell
kubectl taint nodes <node-name> hub.jupyter.org/dedicated=core:NoSchedule
```

This taint can then be viewed by doing:

```shell
kubectl describe nodes | less
```

and searching for `Taints`. You will be able to see which nodes the taints are attached to.

You can remove the taint with (note the \`-\` at the end of the key:effect argument):

```shell
kubectl taint nodes <node-name> hub.jupyter.org/dedicated:NoSchedule-
```

Add the label that the pods will look for when being scheduled on a node:

```shell
kubectl label nodes <node-name> hub.jupyter.org/node-purpose=core
```

You can view this label with:

```shell
kubectl get nodes --show-labels | grep -i core
```

No `kubectl` commands need to be explicitly executed to modify the core pods. The toleration is applied to the core pods [by default](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/HEAD/jupyterhub/values.yaml#L552), however add the following to the `secrets.yaml` in order to make our intentions explicit. It is also noted that, by default, pods are [preferred](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/HEAD/jupyterhub/values.yaml#L563), not required, to spawn on this dedicated core node. Thus, ensure that `scheduling.corePods.nodeAffinity.matchNodePurpose` is set to `require`.

```yaml
scheduling:
  corePods:
    tolerations:
      - key: hub.jupyter.org/dedicated
        operator: Equal
        value: core
        effect: NoSchedule
      - key: hub.jupyter.org_dedicated
        operator: Equal
        value: core
        effect: NoSchedule
    nodeAffinity:
      matchNodePurpose: require
```

After all these changes have been made, run `bash install_jhub.sh` once again to apply them, and run a `kubectl get pods -n jhub -o wide` to confirm that core pods are running on the intended node. Single user pods should no longer be spawned on the dedicated core node, but any preexisting single user pods will may still reside on this node until they are eventually culled by the Hub.

<a id="h-1a179c1a"></a>

### Bug Fix: Remove Username Based Labels from Pods and PVCs

#### Description of Bug

Admin users have the ability to add usernames to the JupyterHub allow list via the admin panel.  This can result in admins adding usernames that start with certain characters that will be escaped by the [Kubespawner](https://github.com/jupyterhub/kubespawner/tree/main), the portion of the JupyterHub that creates single user JupyterLab Pods. The escape character used is a hyphen (`-`), and Kubespawner escapes anything that isn't an `ascii_lowercase` string or a `digits` string (perform a `grep -Rie "safe_chars"` in the `kubespawner/kubespawner` sub-directory to confirm).

When a user logs in, the Kubespawner will create a Pod and PVC (if one does not already exist) with labels based on a user's username (see [here](https://github.com/jupyterhub/kubespawner/blob/cd17869ed4fe0eb9e65dd3bc7b994687a2a72b8e/kubespawner/spawner.py#L638C8-L638C8), [here](https://github.com/jupyterhub/kubespawner/blob/cd17869ed4fe0eb9e65dd3bc7b994687a2a72b8e/kubespawner/spawner.py#L1856), [here](https://github.com/jupyterhub/kubespawner/blob/cd17869ed4fe0eb9e65dd3bc7b994687a2a72b8e/kubespawner/spawner.py#L2091), [here](https://github.com/jupyterhub/kubespawner/blob/cd17869ed4fe0eb9e65dd3bc7b994687a2a72b8e/kubespawner/spawner.py#L1952), and [here](https://github.com/jupyterhub/kubespawner/blob/cd17869ed4fe0eb9e65dd3bc7b994687a2a72b8e/kubespawner/spawner.py#L1868)).  If the first character of this username is escaped, the label will begin with a character that is invalid and rejected by Kubernetes. If the user attempts to spawn their server and [repeatedly fails (default 5 times)](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/5b6e57ed66af8734364e598a008f54ff38efd3ad/jupyterhub/values.yaml#L52), the [entire JupyterHub will crash](https://discourse.jupyter.org/t/spawner-unnecessarily-encoding-capital-letters-leading-to-pvc-creation-errors-and-jhub-crash/17704).  This is a [known bug](https://github.com/jupyterhub/kubespawner/issues/498).

#### "Fixing" The Bug

The [bug fix](https://discourse.jupyter.org/t/advanced-z2jh-deeply-customizing-the-spawner/8432) consists of simply throwing the label away by creating a subclass from the kubespawner class, overriding the `_build_common_labels` method, and telling the JupyterHub configuration to use this new spawner class. You do this by setting the `extraConfig` field in `secrets.yaml`, the Zero to JupyterHub config file.

```yaml
hub:
  extraConfig:
    01-no-labels: |
      from kubespawner import KubeSpawner
      class CustomSpawner(KubeSpawner):
        def _build_common_labels(self, extra_labels):
          labels = super()._build_common_labels(extra_labels)
          # Until https://github.com/jupyterhub/kubespawner/issues/498
          # is fixed
          del labels['hub.jupyter.org/username']
          return labels
      c.JupyterHub.spawner_class = CustomSpawner
```

This _should_ not have any unintended consequences, as this username label is [meant for gathering metrics](https://github.com/jupyterhub/kubespawner/issues/498#issuecomment-1578188004) on individual users, which we don't partake in.

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


<a id="h-8CD654F7"></a>

#### What to Do If Deleting the jhub Namespace Gets Stuck

```sh
kubectl edit svc proxy-public -n jhub
```

Change

```yaml
metadata:
  ...
  finalizers:
    - service.kubernetes.io/load-balancer-cleanup
```

to

```yaml
metadata:
  ...
  finalizers: []
```

Save the file and exit


<a id="h-5F2AA05F"></a>

### Tear Down While Preserving User Volumes

A gentler tear down that preserves the user volumes is described in [Andrea's documentation](https://www.zonca.dev/posts/2018-09-24-jetstream_kubernetes_kubespray_jupyterhub). See the section on "persistence of user data".


<a id="h-801B7EE9"></a>

### Locating and Deleting Orphaned PVCs

Inevitably, when launching and tearing down numerous JupyterHub clusters, there will be times when Persistent Volume Claims (PVCs) and associated OpenStack volumes are orphaned, i.e., not attached to any JupyterHub cluster. These should be periodically cleaned up to not consume the OpenStack volume allocation.

The following set of commands should be done on the JupyterHub control VM where all the clusters are managed from various docker containers, e.g.,:

```sh
$ docker ps
CONTAINER ID   IMAGE                         COMMAND       CREATED        STATUS       PORTS     NAMES
a3b0c55520e9   unidata/science-gateway-gpu   "/bin/bash"   4 weeks ago    Up 4 weeks             unidata-jupyterhub
12769e052f2e   unidata/science-gateway       "/bin/bash"   3 months ago   Up 3 weeks             mvu-test
84625056d84d   unidata/science-gateway       "/bin/bash"   3 months ago   Up 4 weeks             ou23s
ead47ea3eb99   unidata/science-gateway       "/bin/bash"   3 months ago   Up 4 weeks             mvu23s
196a6308afdb   unidata/science-gateway       "/bin/bash"   3 months ago   Up 4 weeks             fsu-s23
```

Also make sure that list is accurate and complete, i.e., all JupyterHub clusters currently running are accounted for. Otherwise, you may miss active PVC volumes that you could potentially accidentally delete.


<a id="h-020D86A3"></a>

#### Obtain PVCs That Are in Use

This command chain performs several actions to get a list of all Kubernetes Persistent Volume Claims (PVCs) within multiple Docker containers, each managing a JupyterHub cluster. The output is then sorted, cleaned of white space, and saved to a file. The end result is that you have a list of all PVCs that are currently in use.

```sh
docker ps -q | xargs -I {} -n1 docker exec -t {} bash -c \
                     'kubectl get pvc -A | tail -n +2' | \
    awk '{print $4}' | sort | tr -d "[:blank:]" > /tmp/pvc.out
```


<a id="h-0ACAC986"></a>

#### Obtain All the OpenStack Volumes

This command chain performs several actions to get a list of all the OpenStack volume names related to PVCs (active or orphaned) from within a specific Docker container. The output is then sorted, cleaned of blanks, and saved to a file. The `container_id` can be chosen from the list of containers described above. It does not matter which one as long as it has access to the OpenStack CLI.

```sh
docker exec -t <container_id> bash -c \
       'source ~/.bashrc && openstack volume list' | grep pvc | \
    awk -F'|' '{print $3}' | sort | tr -d "[:blank:]" > /tmp/pvc-total.out
```


<a id="h-ED8A929F"></a>

#### Find the Orphaned Volumes

Find the orphaned volumes by taking the set difference of the files generated by the last two commands:

```sh
comm -23 /tmp/pvc-total.out /tmp/pvc.out > /tmp/pvc-orphaned.out
```

**Important**: Scrutinize the contents of `/tmp/pvc-orphaned.out` to ensure they are not, in fact, being used anywhere.


<a id="h-D62E010F"></a>

#### Delete Orphaned Volumes

Copy this file into one of the Docker containers listed above. It does not matter which one as long as you have an OpenStack CLI.

```sh
docker ps -q | xargs -I {} -n1 docker cp /tmp/pvc-orphaned.out {}:/tmp/pvc-orphaned.out
```

You can now delete the orphaned volumes with a script the looks like this. Again, think before you type as you are about to delete a number of OpenStack volumes.

```sh
#!/bin/bash

# Source your OpenStack credentials
# source openrc

# Read the file line by line
while IFS= read -r volume_name
do
  # Use the OpenStack CLI to get the volume ID
  volume_id=$(openstack volume show "$volume_name" -f value -c id)
  echo "$volume_name: $volume_id"
  # openstack volume delete $volume_id
done < /tmp/pvc-orphaned.out
```


<a id="h-0E48EFE9"></a>

## Troubleshooting


<a id="h-FF4348F8"></a>

### Unresponsive JupyterHub


<a id="h-C2429D6E"></a>

#### Preliminary Work

If a JupyterHub becomes unresponsive (e.g., 504 Gateway Time-out), login in to the Kubernetes client and do preliminary backup work in case things go badly. First:

```shell
kubectl get pvc -n jhub -o yaml > pvc.yaml.ro
kubectl get pv -n jhub -o yaml > pv.yaml.ro
chmod 400 pvc.yaml.ro pv.yaml.ro
```

Make `pvc.yaml.ro` `pv.yaml.ro` read only since these files could become precious in case you have to do data recovery for users. More on this subject below.


<a id="h-6404011E"></a>

#### Delete jhub Pods

Next, start investigating by issuing:

```shell
kubectl get pods -o wide -n jhub
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


<a id="h-1C4D98E6"></a>

#### Delete jhub, But Do Not Purge Namespace

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


<a id="h-1765D7EB"></a>

#### Background

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


<a id="h-F7B1FC52"></a>

#### Script to Mitigate Problem

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


<a id="h-CB601D7B"></a>

#### Not a Solution but a Longer Term Workaround

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


<a id="h-01F8D10F"></a>

#### Background

Kubernetes clusters use PKI certificates to allow the different components of K8s to communicate and authenticate with one another. See the [official docs](https://kubernetes.io/docs/setup/best-practices/certificates/) for more information. When firing up a JupyterHub cluster using the procedures outlined in this documentation, the certificates are automatically generated for us on cluster creation, however they expire after a full year. You can check the expiration date of your current certificates by running the following on the master node of the cluster:

```shell
sudo kubeadm alpha certs check-expiration
```

Once the certificates have expired, you will be unable to run, for example, `kubectl` commands, and the [control plane components](https://kubernetes.io/docs/setup/best-practices/certificates/) will not be able to, for example, fire up new pods, ie new JupyterLab servers, nor perform `helm` upgrades to the server. Example output of running `kubectl` commands with expired certificates is:

```shell
# kubectl get pods -n jhub
Unable to connect to the server: x509: certificate has expired or is not yet valid: current time 2022-06-29T23:09:31Z is after 2022-06-28T17:38:37Z
```


<a id="h-0A5DF245"></a>

#### Resolution

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


<a id="h-CEF2540C"></a>

### Evicted Pods Due to Node Pressure

If a node starts to run out of resources and you try to fire up new pods on it, the pods will have the "evicted" status associated with them. This can happen when trying to update a JupyterHub whose single user JupyterLab images are large, as Jetstream2's `m3.medium` instances only have `60GB` of disk storage.

This problem was first noticed when updating MVU's JupyterHub, whose single user image was on the order of `10GB`. The new JupyterLab image was going to be similarly large.

Unless otherwise stated, all output of shell commands are from the `mvu-test` cluster.

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

The "Conditions" field describes that the node is undergoing no [Node Pressure](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/). If the node were experiencing some kind of node pressure, attempting to create any pods would cause them to become stuck in the "evicted" state. By [default](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#hard-eviction-thresholds), pods will be evicted from a node if the available storage space on the node falls below `10%`.

Attempting to re-deploy the JupyterHub with a new image will cause the JupyterHub to pull in the new image. If this results in disk pressure, you will see Kubernetes create pods that receive the "Evicted" state:

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

Scrolling to the "Events" section of the `describe node` output, you may find that Kubernetes is attempting to salvage the install by freeing up storage space. This particular output was created while JupyterHub was being upgraded on the "main" `mvu-23s` cluster:

```shell
Events:
  Type     Reason                 Age                From     Message
  ----     ------                 ----               ----     -------
  Warning  EvictionThresholdMet   55m (x4 over 17d)  kubelet  Attempting to reclaim ephemeral-storage
  Normal   NodeHasDiskPressure    55m (x4 over 17d)  kubelet  Node mvu23s-k8s-node-nf-9 status is now: NodeHasDiskPressure
  Normal   NodeHasNoDiskPressure  50m (x5 over 29d)  kubelet  Node mvu23s-k8s-node-nf-9 status is now: NodeHasNoDiskPressure
```

In this case, Kubernetes successfully performed garbage collection and was able to recover enough storage space to complete the install after some period of waiting.

If Kubernetes is taking too long to want to perform garbage collection, there is a very hacky work-around to this. Cancel the installation (`ctrl-c`), and run `helm uninstall jhub -n jhub`. This will uninstall the JupyterHub from the cluster, however, importantly it will [keep user data intact](https://www.zonca.dev/posts/2018-09-24-jetstream_kubernetes_kubespray_jupyterhub#delete-and-reinstall-jupyterhub).

Through some inspection, you may find that the worker nodes contain a cache of not only the single user image which is currently deployed, but the previous one as well:

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

The work-around is to force the removal of one of the images by installing a small single user image in the JupyterHub that you know will fit on the node's available storage space. The [jupyter/base-notebook](https://hub.docker.com/r/jupyter/base-notebook/tags) image is a good candidate for this. Edit the appropriate sections of `secrets.yaml` to install this smaller image, run `bash install_jhub.sh`, and watch `kubectl get pods -n jhub` to ensure everything installs correctly. Kubernetes should have purged one of the previous images and freed up storage space. Now, re-edit `secrets.yaml` and install the image you desire.


<a id="h-FABFCED0"></a>

### Updating Openstack Credentials for Kubernetes

If your openstack credentials expire, you will be unable to run even basic `openstack` commands such as `openstack server list`. Generally, this would not be a pressing issue, as instances that are already running should stay running. However, expired openstack credentials pose a large problem for JupyterHubs that have been deployed using Kubernetes, as K8s uses openstack credentials to communicate with the Jetstream2 cloud and perform essential functions such as mounting openstack volumes on pods. This results in the user receiving a message such as the following when attempting to spawn their single user server:

```
Your server is starting up.
You will be redirected automatically when it's ready for you.
72% Complete
2023-04-14T16:39:44Z [Warning] Unable to attach or mount volumes: unmounted volumes=[volume-<user>], unattached volumes=[volume-<user>]: timed out waiting for the condition
Event log
```

Doing a `kubectl describe pod -n jhub <single-user-pod>` on the offending pod will reveal that the volume is failing to attach due to an authentication issue.


<a id="h-6F9D771F"></a>

#### Creating New Credentials

Follow the instructions in the [Jetstream2 docs](https://docs.jetstream-cloud.org/ui/cli/auth/#using-the-horizon-dashboard-to-generate-openrcsh) to navigate to the "Application Credentials" page of the Horizon interface. From here, you can verify that your credentials are expired and create a new set of credentials.

Once you've created the new credentials, you can update any necessary `openrc.sh` files. Note that it is [important](https://medium.com/@jonsbun/why-need-to-be-careful-when-mounting-single-files-into-a-docker-container-4f929340834) to use a text editor, such as `nano`, that will not change the inode of the file being edited, as docker mounts files by their inode and not their file name. Once this has been done, you will have to re-source `openrc.sh` for the changes to take effect: `source /path/to/openrc.sh`. Ensure you are able to use these new credentials to run openstack commands: `openstack server list`.


<a id="h-4126F02C"></a>

#### Updating Credentials in K8s

Start a shell with `kubectl` capabilities for the cluster. Follow Andrea Zonca's [instructions](https://www.zonca.dev/posts/2023-03-23-update-openstack-credentials-kubernetes) to update the credentials. The procedure is outlined below, and has to be repeated for two Kubernetes [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/), `external-openstack-cloud-config` and `cloud-config`.

```
# Print out the base64 encoded secret
kubectl get secret -n kube-system <secret-name> -o jsonpath='{.data}'

# Copy/paste the secret to decode it; dump to file
echo <secret> | base64 --decode > /tmp/cloud.conf

# Update the temporary with the new credentials
vim /tmp/cloud.conf

# Re-encode the secret; copy the terminal output
cat /tmp/cloud.conf | base64 -w0

# Edit update the K8s secret
kubectl edit secret -n kube-system <secret-name>
```

Once both secrets have been updated, restart the cluster via openstack for changes to take effect

```
# Ensure you're rebooting what you think you are
for INSTANCE in $(openstack server list -c Name -f value | grep <PATTERN>); do echo "openstack server reboot $INSTANCE"; done
# Reboot
for INSTANCE in $(openstack server list -c Name -f value | grep <PATTERN>); do openstack server reboot $INSTANCE; done
```


<a id="h-761EE5B5"></a>

### Persistent File/Directory Permissions e.g., ~/.ssh

If a user changes ownership or permissions to files/directories in their home directories, for example by using `chmod`, they will be surprised to find that these file permissions have been reset the next time they spawn their server (i.e., Pod). This situation can arise when, for example, an instructor uses the JupyterHub to push updated material to GitHub using ssh key authentication, in which the permissions of the `~/.ssh` directory, as well as the private and public key pair, need to be set in a certain manner. First, a brief explanation for why this happens is presented, followed by a simple workaround.


<a id="h-7275F48A"></a>

#### Why This Occurs

A user's data exists on Openstack volumes which are created and managed by Kubernetes via the `cinder-csi` storage class and driver. Ultimately, Kubernetes exposes these volumes to pods via PersistentVolumeClaims. When a user logs into the JupyterHub, their persistent volume is mounted onto the pod as it spins up. According to the Kubernetes [docs on configuring pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods), "Kubernetes recursively changes ownership and permissions for the contents of each volume to match the `fsGroup` specified in a Pod's `securityContext` when that volume is mounted." Thus, this behavior is a consequence of Kubernetes re-mounting an openstack volume onto a user's pod.


<a id="h-FB656610"></a>

#### Simple Workaround

This security context described can be [specified](https://z2jh.jupyter.org/en/stable/resources/reference.html#hub-podsecuritycontext) when installing the JupyterHub (see default value [here](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/56c921de05ffeed559fe906972975856e4639cb6/jupyterhub/values.yaml#L86)). However, it seems fine grained permissions are either difficult or highly inconvenient to accommodate. To work around this there is a solution for two cases:

1.  If the permissions change is desired for a single user, that user can include their `chmod` commands in one of the profile files read by `bash` (see NOTE below).
2.  If the permission change is desired for all users, have the user contact the Unidata Science Gateway team with a request for the permissions change. Science Gateway staff will then be able to make this `chmod` command take place on pod startup via `secrets.yaml`. See the example below which updates the permissions for the `~/.ssh` directory:

```yaml
# secrets.yaml
singleuser:
  lifecycleHooks:
    postStart:
      exec:
        command:
          - "sh"
          - "-c"
          - >
            <other startup commands>;
            dir="/home/jovyan/.ssh";
            [ -d $dir ] && { chmod 700 $dir && chmod -f 600 $dir/* && chmod -f 644 $dir/*.pub; } || true
```

NOTE: See the INVOCATION section of `man 1 bash` for a full explanation of which configuration files are sourced, and in what order they are searched for.
