- [Creating  a JupyterHub on Jetstream with the Zero to JuypyterHub Project](#h:D73CBC56)
  - [Kubernetes Cluster](#h:65F9358E)
  - [unidata/unidatahub Docker Container](#h:CD007D2A)
  - [Configure and Deploy the JupyterHub](#h:E5CA5D99)
    - [Letsencrypt versus Certificate from a Certificate Authority](#h:294A4A20)
    - [OAuth Authentication](#h:8A3C5434)
    - [unidata/unidatahub](#h:214D1D4C)
  - [Navigate to JupyterHub](#h:209E2FBC)
  - [Tearing Down JupyterHub](#h:1E027567)
    - [Total Destructive Tear Down](#h:A69ADD92)
    - [Tear Down While Preserving User Volumes](#h:5F2AA05F)



<a id="h:D73CBC56"></a>

# Creating  a JupyterHub on Jetstream with the Zero to JuypyterHub Project


<a id="h:65F9358E"></a>

## Kubernetes Cluster

[Create a Kubernetes cluster](../../openstack/readme.md) with the desired number of nodes and VM sizes. Lock down the master node of the cluster per Unidata security procedures. Work with sys admin staff to obtain a DNS name (e.g., jupyterhub.unidata.ucar.edu), and a certificate from a certificate authority for the master node.


<a id="h:CD007D2A"></a>

## unidata/unidatahub Docker Container

Build the Docker container in this directory and push it to dockerhub.

```sh
docker build -t unidata/unidatahub:`openssl rand -hex 6` . > /tmp/docker.out 2>&1 &
docker push unidata/unidatahub:<container id>
```


<a id="h:E5CA5D99"></a>

## Configure and Deploy the JupyterHub

From the client host where you created the Kubernetes cluster, follow [Andrea Zonca's instructions](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html).

After you have created the `secrets.yaml` as instructed, customize it with the choices below


<a id="h:294A4A20"></a>

### Letsencrypt versus Certificate from a Certificate Authority

1.  Letsencrypt

    Follow [Andrea's instructions](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html) on setting up letsencrypt along with this yaml snippet below. Replace the hostname where appropriate.
    
    ```yaml
    ingress:
      enabled: true
      annotations:
        kubernetes.io/tls-acme: "true"
      hosts:
        - <jupyterhub-host>
      tls:
          - hosts:
             - <jupyterhub-host>
            secretName: certmanager-tls-jupyterhub
    ```

2.  Certificate from CA

    Work with sys admin staff to obtain a certificate from a CA.
    
    Follow [Andrea's instructions](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html) on setting up HTTPS with custom certificates.
    
    ```yaml
    ingress:
      enabled: true
      annotations:
        kubernetes.io/tls-acme: "true"
      hosts:
        - <jupyterhub-host>
      tls:
          - hosts:
             - <jupyterhub-host>
            secretName: <secret_name>
    ```


<a id="h:8A3C5434"></a>

### OAuth Authentication

1.  Globus

    [Globus OAuth capability](https://developers.globus.org/) is available for user authentication. The instructions [here](https://github.com/jupyterhub/oauthenticator#globus-setup) are relatively straightforward.
    
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


<a id="h:214D1D4C"></a>

### unidata/unidatahub

Add the Unidata JupyterHub configuration (`unidata/unidatahub`) and related items (e.g., pulling of Unidata Python projects). Customize the desired CPU / RAM usage. [This spreadsheet](https://docs.google.com/spreadsheets/d/15qngBz4L5gwv_JX9HlHsD4iT25Odam09qG3JzNNbdl8/edit?usp=sharing) will help you determine the size of the cluster based on number of users, desired cpu/user, desired RAM/user. Duplicate it and adjust it for your purposes.

```yaml
singleuser:
  storage:
    capacity: 10Gi
  startTimeout: 600
  memory:
    guarantee: 2G
    limit: 2G
  cpu:
    guarantee: 0.5
    limit: 0.75
  defaultUrl: "/lab"
  image:
    name: unidata/unidatahub
    tag: 5d5d0301d334
  lifecycleHooks:
    postStart:
      exec:
          command:
            - "sh"
            - "-c"
            - >
              gitpuller https://github.com/julienchastang/unidata-python-workshop master python-workshop;
              gitpuller https://github.com/julienchastang/unidata-python-gallery-mirror master notebook-gallery;
              gitpuller https://github.com/julienchastang/online-python-training master online-python-training;
              cp /README_FIRST.ipynb /home/jovyan

hub:
  extraConfig: |-
    c.Spawner.cmd = ['jupyter-labhub']
    c.JupyterHub.template_vars = {'announcement': '<h3>This JupyterHub server will be down for maintenance Friday, June 8. PLEASE make local backups of your important notebooks!</h3>'}
```


<a id="h:209E2FBC"></a>

## Navigate to JupyterHub

In a web browser, navigate to your newly minted JupyterHub and see if it is as you expect.


<a id="h:1E027567"></a>

## Tearing Down JupyterHub


<a id="h:A69ADD92"></a>

### Total Destructive Tear Down

Tearing down the JupyterHub including user OpenStack volumes is possible. From the Helm and Kubernetes client:

```sh
helm delete jhub --purge
kubectl delete namespace jhub
```

To futher teardown the Kubernetes cluster see [Tearing Down the Cluster](../../openstack/readme.md).


<a id="h:5F2AA05F"></a>

### Tear Down While Preserving User Volumes

A gentler tear down that preserves the user volumes is described in [Andrea's documentation](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html). See the section on "persistence of user data".
