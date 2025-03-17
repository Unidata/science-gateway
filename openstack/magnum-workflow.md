# Deploying a JupyterHub Using Openstack Magnum

## Table of Contents

- [Intro](#Intro)
- [Useful Links](#Useful-Links)
- [Provisioning a Cluster With Magnum](#Provisioning-a-Cluster-With-Magnum)
  - [Launching the Science Gateway Docker Image](#Launching-the-Science-Gateway-Docker-Image)
  - [Launching the Magnum Cluster](#Launching-the-Magnum-Cluster)
    - [Fetch the kubectl config File](#Fetch-the-kubectl-config-File)
  - [Install an Ingress Resource](#Install-an-Ingress-Resource)
  - [Create an A Record](#Create-an-A-Record)
  - [Get a Certificate from LetsEncrypt](#Get-a-Certificate-from-LetsEncrypt)
  - [Nodegroups](#Nodegroups)
    - [Create Nodegroups](#Create-Nodegroups)
- [Install JupyterHub](#Install-JupyterHub)
  - [Create the JupyterLab Image](#Create-the-JupyterLab-Image)
  - [Creating a GitHub OAuth App](#Creating-a-GitHub-OAuth-App)
  - [Deploy JupyterHub Via Helm](#Deploy-JupyterHub-Via-Helm)
    - [Scheduling the Core Pods](#Scheduling-the-Core-Pods)
    - [Scheduling the Single User Pods](#Scheduling-the-Single-User-Pods)
    - [Installing JupyterHub](#Installing-JupyterHub)
- [Cluster Teardown](#Cluster-Teardown)

## Intro

Magnum is Openstack's "Kubernetes as a Service" (KaaS) project. With Magnum, we
no longer need to follow the old Kubespray workflow to deploy Kubernetes
clusters, a lengthy process that can take between 30 minutes up to an hour,
depending the cluster size--instead taking as few as 10 minutes to get a cluster
fully online. In addition, Magnum brings with it cluster auto-scaling, enabling
clusters to use minimal resources while no users are accessing the cluster while
allowing users to access powerful resources on-demand. It's been observed that a
cluster can add a new node and make it available to JupyterHub in approximately
5 minutes.

## Useful Links

[Andrea Zonca's Magnum Blog Post](https://www.zonca.dev/posts/2024-12-11-jetstream_kubernetes_magnum)
[Magnum User Guide](https://docs.openstack.org/magnum/latest/user/)

## Provisioning a Cluster With Magnum

The procedure to provision the cluster follows [Andrea Zonca's Magnum Blog
Post](https://www.zonca.dev/posts/2024-12-11-jetstream_kubernetes_magnum) with
some minor modifications to integrate it with Unidata's workflow.

### Launching the Science Gateway Docker Image

Unidata has a `unidata/science-gateway` docker image that should have all the
necessary tools pre-installed.

Log in to the `jupyter-ctrl` machine and navigate to
`~/science-gateway/openstack`. Then run `./jupyterhub.sh` with the appropriate
arguments. These arguments are described when running the script without any
args:

```bash
./jupyterhub.sh
Syntax: jupyterhub.sh [-h] [-n] [-p] [-o] [-g]
script to fire up or access a Z2J JupyterHub.
	-h show this help text
	-n, --name JupyterHub name
	-p, --ip JupyterHub IP
	-o, --openrc openrc.sh path
	-g, --gpu
```

As of the time of this doc's writing, the `--ip` arg is necessary to run the
script, but not necessary to launch the Magnum cluster. Supply the script with
some dummy IP such as `127.0.0.1`. For example:

```bash
./jupyterhub.sh --name my-cluster --ip 127.0.0.1 --openrc $(pwd)/my-openrc.sh
```

You should now be running a shell in the science gateway image. All following
steps in this instruction set are done from within this container.

If you think you might not have the `python-magnumclient` package, install it
now with:

```bash
pip3 install python-magnumclient
```

### Launching the Magnum Cluster

The container should be preconfigured to have pulled Andrea Zonca's
[jupyterhub-deploy-kubernetes-jetstream](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream)
repository which contains many useful scripts for not only deploying the
cluster, but installing JupyterHub on top of it.

Navigate to `~/jupyterhub-deploy-kubernetes-jetstream/kubernetes_magnum`

Here you'll find the `create_cluster.sh` script. Before running it, we must:

1) `export K8S_CLUSTER_NAME=$CLUSTER`
    - Ensure the parameter is set as expected
    - `echo $K8S_CLUSTER_NAME`
2) Edit the parameters found in `create_cluster.sh` to their desired values:
    - `FLAVOR`: the flavor of the default worker node
        - Recommended at least `m3.quad`
    - `TEMPLATE`: the Magnum template, in practice this determines the K8s
       cluster version
        - See also: `openstack coe cluster template list`
    - `MASTER_FLAVOR`: the flavor of the control-plane nodes
        - Recommended at least `m3.quad`
    - `N_MASTER`: the number of control-plane nodes
        - Recommned 1
    - `N_NODES`: the number of worker nodes
        - Recommend to leave as 1
        - See NOTE below
3) Edit the `openstack cluster create` command found in `create_cluster.sh` to
   include the `--fixed-network auto_allocated_network` argument
    - This ensures the newly created cluster will be on the same network/subnet
      as our `fluentbit` machine which will gather logs
    - Without this, Magnum would create a new set of network resources, which
      may be undesireable
4) Edit the `max_node_count` label to equal 1
    - See NOTE below
5) If this cluster is *not* intended to auto-scale, remove the `--labels
   auto_scaling_enabled=true` line
6) Add the keypair argument `--keypair jupyter-ctrl-k8s`

> NOTE:
> We leave the number of default worker nodes to 1, as we plan on using this
> node as the "jupyter core" machine, that will additionally contain the
> ingress-nginx pod. Having a max/min of 1 node ensures that this node will
> never be unintentionally downscaled. This stability allows us the option to
> configure this node for heightened security.
>
> An additional "Nodegroup" will be created to host the JupyterLab single-user
> Pods

After having performed all the above steps, run `bash create_cluster.sh`. In
addition to creating the cluster, the script is written to display the status of
the cluster creation every minute and will exit whenever the cluster creation
has completed, this process could take as few at 10 minutes.

#### Fetch the kubectl config File

Once the cluster has been successfully created, we must fetch the `config` file
that allows us to interact with the cluster via `kubectl`. Run the following
commands:

```bash
openstack coe cluster config $CLUSTER --force
chmod 600 config
mkdir -p ~/.kube/
mv config ~/.kube/config
```
You should now be able to run `kubectl` commands, such as `kubectl get nodes`.

### Install an Ingress Resource

An ingress resource allows traffic into the cluster and in necessary for HTTPS.
Install it using `helm` as described in [Andrea's
tutorial](https://www.zonca.dev/posts/2024-12-11-jetstream_kubernetes_magnum#install-nginx-controller)
with one modification. Namely, we specify that we require the nginx Pod to run

on the `default-worker` node with the `--set` flag:
```bash
helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace \
    --set 'controller.nodeSelector.capi\.stackhpc\.com/node-group=default-worker'
```

After some time, you should see the ingress' service resource with a:

```bash
kubectl get svc -n ingress-nginx
```

Take note of the public IP address that was created for you, as this will be
used below to create an "A record".

### Create an A Record

Create an "A record", i.e. a subdomain name, for users to access the cluster.

Find your zone:

```bash
openstack zone list
```

For Unidata, this should return `ees220002.projects.jetstream-cloud.org.`

Create the A record in this zone, where `$IP` is the IP address of your
ingress' service resource:

```bash
openstack recordset create  ees220002.projects.jetstream-cloud.org. $K8S_CLUSTER_NAME --type A --record $IP --ttl 3600
```

You should now be able to access
`$K8S_CLUSTER_NAME.ees220002.projects.jetstream-cloud.org`. At this stage,
you'll see a blank nginx page, since we haven't set up any services, such as
JupyterHub, yet.

### Get a Certificate from LetsEncrypt

A certificate from LetsEncrypt allows secure connections via HTTPS and is
obtained via the standard method.

Navigate to `~/jupyterhub-deploy-kubernetes-jetstream/setup_https`.

Edit `https_cluster_issuer.yaml` to include the `letsencrypt@unidata.ucar.edu`
email address.

Deploy the cert manager Pods by applying the manifest from GitHub:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
```

Apply the cluster issuer manifest:

```bash
kubectl apply -f https_cluster_issuer.yml
```

Your cluster should now be ready to request and obtain a certificate.

### Nodegroups

[Nodegroups](https://docs.openstack.org/magnum/latest/user/#node-groups) allow
cluster administors to "create heterogenous clusters", i.e. clusters made of
different flavors of nodes created for specific purposes.

As described in the NOTE above when discussing the cluster creation, we will
create a nodegroup to host the JupyterLab single user Pods. The nodes of all
nodegroups, including the `default-master` and `default-worker` will have a
Kubernetes label corresponding to the nodegroup name. For example, all nodes of
the `default-worker` nodegroup will have the following label:

`capi.stackhpc.com/node-group=default-worker`

This is useful, as [nodeSelectors and
labels](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
can be used to ensure Pods are scheduled on certain nodes. One immediate
application of this is the ability to allow science gateway users the freedom to
decide which flavor of machine they want to launch their server on.

#### Create Nodegroups

The following command will create a new auto-scaling nodegroup named `mediums`
with a maximum of 8 nodes:

```bash
openstack coe nodegroup create $CLUSTER mediums \
    --node-count 1 \
    --flavor m3.medium \
    --labels auto_scaling_enabled=true \
    --min-nodes 1 \
    --max-nodes 8
```

If your cluster is *not* an autoscaling cluster, remove the `--labels
auto_scaling_enabled=true` argument. If desired, you can make the `--min-nodes`
argument a number higher than 1. This means the cluster will have more idling
resources, but has the potential for a faster user experience, as they will be
able to immediately access the resources without triggering the auto-scaler.

After a short amount of time, ~5 minutes, you should see the new node(s) in the
output of a `kubectl get nodes`.

## Install JupyterHub

### Create the JupyterLab Image

Branch the `science-gateway` repo and make a copy of the
`./jupyter-images/shared` directory. Name it the same as the cluster name.

Edit the environment file and Dockerfile to fit the needs of the requester. Any
additional packages can also be installed into this image.

Edit `secrets.yaml` and `update_material.ipynb`, while ensuring you keep all
sensitive information redacted.

Commit your changes and push your branch to your fork.

Connect to the `docker` machine on Jetstream2, checkout your branch, and build
the docker image. Use `./build.sh <cluster-name>`.

You can include the `--push` flag as an argument to the above script to also
push the docker image to DockerHub, or push it manually with:

```bash
docker push unidata/<cluster-name>:<tag>
```

### Creating a GitHub OAuth App

We use GitHub OAuth to authenticate our users. As such, we must create a GitHub
OAuth App. This is straightforward and can be done via GitHub's "Developer
Settings" page.

You will have to create a secret and paste it into the `secrets.yml` config once
you have the cluster running, however, make sure to not leak the secrets by
committing it to the science gateway repo.

### Deploy JupyterHub Via Helm

Finally, we can ensure that all the configurations in `secret.yaml` are set
appropriately and deploy the JupyterHub.

#### Scheduling the Core Pods

We intend to schedule the JupyterHub core pods in the lone `default-worker`
node for stability. We accomplish this by applying a label to the
`default-worker` node and including a configuration option when installing
JupyterHub.

Apply the label to the `default-worker`:

```bash
kubectl label nodes <default-worker-node-name> hub.jupyter.org/node-purpose=core
```

Include this snippet in `secrets.yaml`. It is found in the skeleton
`secrets.yaml`, so it must only be un-commented:

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

#### Scheduling the Single User Pods

We schedule the single user JupyterLab Pods on one or multiple of our
nodegroups. This is done by specifying a `nodeSelector` in JupyterHub's
`secrets.yaml`. This `nodeSelector` selects for the
`capi.stackhpc.com/node-group` label that is automatically assigned to nodes of
a nodegroup.

The following example uses a
[profileList](https://z2jh.jupyter.org/en/latest/resources/reference.html#singleuser-profilelist)
to gives users the option of a Low Power and High Power machine, and uses the
`mediums` nodegroup from the example above:

```yaml
singleuser:
  profileList:
  - display_name: "Low Power (m3.small)"
    default: true
    description: "4 GB of memory; 1.5 vCPUS"
    kubespawner_override:
      mem_guarantee: 4G
      mem_limit: 4G
      cpu_guarantee: 1.5
      cpu_limit: 1.5
      node_selector:
        capi.stackhpc.com/node-group: default-worker
  - display_name: "Low Power (m3.medium)"
    description: "4 GB of memory; 1.5 vCPUS"
    kubespawner_override:
      mem_guarantee: 4G
      mem_limit: 4G
      cpu_guarantee: 1.5
      cpu_limit: 1.5
      node_selector:
        capi.stackhpc.com/node-group: mediums
```

If you do not wish to have different profile options, you can instead use the
following:

```yaml
singleuser:
  nodeSelector:
    capi.stackhpc.com/node-group: mediums
```

#### Installing JupyterHub

First, navigate to `~/jupyterhub-deploy-kubernetes-jetstream` and configure
`helm` to pull from the JupyterHub repo:

```bash
./configure_helm_jupyterhub.sh
```

Install JupyterHub:

```bash
./install_jhub.sh`
```

Navigate to your cluster's URL and verify that the connection is secure (HTTPS
in working) and that you can login with your GitHub credentials. This may take a
moment as cert manager requests and aquires the certificate. You can see the
status of the certificate and certificate request with:

```bash
kubectl get certificate -n jhub
kubectl get certificaterequest -n jhub
```

## Cluster Teardown

Tearing down the cluster is made simple by Magnum.

Previously with the Kubespray workflow, it was necessary to delete the `jhub`
namespace before tearing down the cluster so as to not "orphan" any openstack
volumes that were created as PVCs. With Magnum, this step can be skipped. If you
wanted to confirm that these volumes are destroyed with the rest of the cluster,
first get a list of PVCs:

```bash
kubectl get pv -A | tail -n +2 | cut -f 1 -d " " > /tmp/pv.out
```

You can see the volumes via openstack with:

```bash
openstack volume list | grep -f /tmp/pv.out
```

Now, destroy the cluster with the
`~/jupyterhub-deploy-kubernetes-jetstream/kubernetes_magnum/delete_cluster.sh`
script:

```bash
echo $K8S_CLUSTER_NAME # Ensure you're deleting the right cluster
cd ~/jupyterhub-deploy-kubernetes-jetstream/kubernetes_magnum
bash delete_cluster.sh
```

The script will provide a status for the cluster deletion.

Once it's been deleted, ensure the PVs have been deleted along with the cluster:

```bash
openstack volume list | grep -f /tmp/pv.out
```

Finally, we delete the A record that was created to point to the load balancer
IP:

```bash
openstack recordset list ees220002.projects.jetstream-cloud.org. -c name -c id | grep $K8S_CLUSTER_NAME
openstack recordset delete ees220002.projects.jetstream-cloud.org. $K8S_CLUSTER_NAME.ees220002.projects.jetstream-cloud.org.
```
