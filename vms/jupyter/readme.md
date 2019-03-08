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
    - [Tear Down While Preserving User Volumes and Master Node IP](#h:5F2AA05F)



<a id="h:D73CBC56"></a>

# Creating  a JupyterHub on Jetstream with the Zero to JuypyterHub Project


<a id="h:65F9358E"></a>

## Kubernetes Cluster

[Create a Kubernetes cluster](https://github.com/Unidata/xsede-jetstream/tree/master/openstack#building-a-kubernetes-cluster) with the desired number of nodes and VM sizes. Lock down the master node of the cluster per Unidata security procedures. Work with sys admin staff to obtain a DNS name (e.g., jupyterhub.unidata.ucar.edu), and a certificate from a certificate authority for the master node.


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

    Follow [Andrea's instructions](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html) on setting up letsencrypt along with this yaml snippet:
    
    ```yaml
    ingress:
      enabled: true
      annotations:
        kubernetes.io/tls-acme: "true"
      hosts:
        - jupyterhub.unidata.ucar.edu
      tls:
          - hosts:
             - jupyterhub.unidata.ucar.edu
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
        - jupyterhub.unidata.ucar.edu
      tls:
          - hosts:
             - jupyterhub.unidata.ucar.edu
            secretName: <cert-secret>
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
        callbackUrl: "https://jupyterhub.unidata.ucar.edu:443/oauth_callback"
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
        callbackUrl: "https://<your-domain-name>:443/oauth_callback"
      admin:
        users:
          - adminuser1
    ```


<a id="h:214D1D4C"></a>

### unidata/unidatahub

Add the Unidata JupyterHub configuration (`unidata/unidatahub`). Customize cpu and memory according to size of cluster and expected number of students. Based on those assumptions shoot for 80% capacity. For example, if your cluster has 100 CPUs and you expect 80 students allow for a cpu limit of 1. The same reasoning applies for the memory settings. Adjust your arithmetic accordingly for cluster size and expected number of users.

```yaml
singleuser:
  startTimeout: 600
  memory:
    guarantee: 1G
    limit: 4G
  cpu:
    guarantee: 1
    limit: 2
  defaultUrl: "/lab"
  image:
    name: unidata/unidatahub
    tag: <container id>
  lifecycleHooks:
    postStart:
      exec:
          command:
            - "sh"
            - "-c"
            - >
              gitpuller https://github.com/Unidata/python-workshop master python-workshop;
              gitpuller https://github.com/julienchastang/unidata-python-gallery-mirror master notebook-gallery;
              gitpuller https://github.com/Unidata/online-python-training master online-python-training;
              cp /README_FIRST.ipynb /home/jovyan
hub:
  extraConfig: |-
    c.Spawner.cmd = ['jupyter-labhub']
```


<a id="h:209E2FBC"></a>

## Navigate to JupyterHub

In a web browser, navigate to [https://jupyterhub.unidata.ucar.edu](https://jupyter-jetstream.unidata.ucar.edu).


<a id="h:1E027567"></a>

## Tearing Down JupyterHub


<a id="h:A69ADD92"></a>

### Total Destructive Tear Down

Tearing down the JupyterHub including user OpenStack volumes is possible. From the Helm and Kubernetes client:

```sh
helm delete jhub --purge
kubectl delete namespace jhub
```

followed by

```sh
terraform_destroy.sh.
```


<a id="h:5F2AA05F"></a>

### Tear Down While Preserving User Volumes and Master Node IP

A gentler tear down that preserves the user volumes and master node IP is described in [Andrea's documentation](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html). See the section on "persistence of user data".
