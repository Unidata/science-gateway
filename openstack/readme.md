- [Running VMs on Jetstream with OpenStack](#h-90A8A74D)
  - [Introduction](#h-11F59F95)
  - [Install Docker (Do This Once)](#h-DE5B47F1)
  - [Clone the xsede-jetstream Repository (Do This Once)](#h-968FA51C)
  - [Pull or Build Docker Container (Do This Once)](#h-4A9632CC)
    - [Pull Container](#h-B5690030)
    - [Build Container](#h-1C54F677)
  - [API Setup](#h-CBD5EC54)
    - [Download and Edit openrc.sh (Do This Once)](#h-8B3E8EEE)
    - [Fire Up Container and More Setup](#h-30B73273)
  - [Working with Jetstream API to Create VMs](#h-03303143)
    - [IP Numbers](#h-5E7A7E65)
    - [Boot VM](#h-EA17C2D9)
    - [Create and Attach Data Volumes](#h-9BEEAB97)
    - [Opening TCP Ports](#h-D6B1D4C2)
    - [Tearing Down VMs](#h-1B38941F)
    - [Swapping VMs](#h-56B1F4AC)
  - [Building a Kubernetes Cluster](#h-DA34BC11)
    - [Define cluster with cluster.tf](#h-F44D1317)
    - [Create VMs with kube-setup.sh](#h-0C658E7B)
    - [Install Kubernetes with kube-setup2.sh](#h-05F9D0A2)
    - [Check Cluster](#h-D833684A)
    - [Adding Nodes to Cluster](#h-1991828D)
    - [Removing Nodes from Cluster](#h-0324031E)
    - [Tearing Down the Cluster](#h-DABDACC7)
    - [Monitoring the Cluster with Grafana and Prometheus](#h-005364BF)
- [Appendix](#h-78283D4A)
  - [Jetstream VM Flavors](#h-958EA909)



<a id="h-90A8A74D"></a>

# Running VMs on Jetstream with OpenStack


<a id="h-11F59F95"></a>

## Introduction

It is preferable to interface with the NSF Jetstream cloud via the [Atmosphere web interface](https://use.jetstream-cloud.org/application/dashboard). However, this web dashboard is limited in two important ways:

1.  Users cannot obtain VMs with static IPs
2.  Users cannot open low number ports (i.e., < `1024`) with the exception of ports `22`, `80` and `443` which are open by default.

If you are in either of these scenarios, you have to interface with Jetstream via the [OpenStack API](https://iujetstream.atlassian.net/wiki/display/JWT/Using+the+Jetstream+API). The problem here is that there is some initial setup which is somewhat painful but that you do only once. We provide a Docker container that hopefully eases some of the pain as it has the OpenStack command line tools and convenience scripts installed. After that setup, you can interface with the Jetstream OpenStack command line via the `openstack.sh` script which will launch a Docker container that will enable you to:

-   Create IP Numbers
-   Create VMs
-   Tear down VMs
-   Create Data Volumes
-   Attach Data Volumes
-   Open TCP ports

Note, you do not have to employ this Docker container. It is merely provided as a convenience. If you choose, you can go through the Jetstream OpenStack API instructions directly and ignore all that follows.


<a id="h-DE5B47F1"></a>

## Install Docker (Do This Once)

[Install Docker](../vm-init-readme.md) in your computing environment because we will be interacting with the OpenStack Jetstream API via Docker. This step should make our lives easier.


<a id="h-968FA51C"></a>

## Clone the xsede-jetstream Repository (Do This Once)

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```sh
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h-4A9632CC"></a>

## Pull or Build Docker Container (Do This Once)

```sh
cd xsede-jetstream/openstack
```

At this point, you can either pull or build the `xsede-jetstream` container:


<a id="h-B5690030"></a>

### Pull Container

```sh
docker pull unidata/xsede-jetstream
```


<a id="h-1C54F677"></a>

### Build Container

```sh
docker build -t unidata/xsede-jetstream .
```


<a id="h-CBD5EC54"></a>

## API Setup

We will be using the Jetstream API directly and via convenience scripts.


<a id="h-8B3E8EEE"></a>

### Download and Edit openrc.sh (Do This Once)

The next part involves downloading the `openrc.sh` file to work with our OpenStack allocation. You will have first login to the OpenStack TACC dashboard which will necessitate a password reset. Unfortunately, this login is not the same as the Jetstream Atmosphere web interface login. Also, follow the usual password advice of not reusing passwords as this password will end up in your OpenStack environment and [you may want to add it](#h-9C0700C5) in the `openrc.sh` file for convenience.

1.  [Reset your OpenStack TACC dashboard password](https://portal.tacc.utexas.edu/password-reset/)

2.  Download your `openrc.sh` file from the IU (not TACC) dashboard at  <https://iu.jetstream-cloud.org> and move it to the `openstack/bin` directory.

    -   See *"Use the Horizon dashboard to generate openrc.sh"* in the [Jetstream API instructions](https://iujetstream.atlassian.net/wiki/display/JWT/Setting+up+openrc.sh).
    -   From the [IU dashboard](https://iu.jetstream-cloud.org/project/api_access/), navigate to `Project`, `API Access`, then select `Download OpenStack RC File` at top-right.
    -   Select **OpenStack RC File (Identity API 3)** , which will download as a script named something like `TG-ATM160027-openrc.sh`. You should rename it to `openrc.sh`.
    -   Move this file to `bin/openrc.sh` (e.g., `/home/jane/xsede-jetstream/openstack/bin/openrc.sh`).

3.  Edit `bin/openrc.sh` Password (Optional)

    For convenience, you may wish to add your password to the `openrc.sh` file. Again, follow the usual advice of not reusing passwords as this password will end up in your OpenStack environment.

    Edit the `openrc.sh` file and the supply the TACC resource `OS_PASSWORD` you [reset earlier](#h-8B3E8EEE):

    ```sh
    export OS_PASSWORD="changeme!"
    ```

    Comment out

    ```sh
    # echo "Please enter your OpenStack Password: "
    # read -sr OS_PASSWORD_INPUT
    ```


<a id="h-30B73273"></a>

### Fire Up Container and More Setup

1.  openstack.sh

    Start the `unidata/xsede-jetstream` container with `openstack.sh` convenience script. The script take a `-o` argument for your `openrc.sh` file and a `-s` argument for the directory containing or will contain your ssh keys (e.g., `/home/jane/xsede-jetstream/openstack/ssh` or a new directory that will contain contain your Jetstream OpenStack keys that we will be creating shortly). **Both arguments must be supplied with fully qualified path names.**

    ```sh
    chmod +x openstack.sh
    ./openstack.sh -o </path/to/your openrc.sh file> -s </path/to/your/ssh directory>
    ```

    Subsequently, when interacting with Jetstream via OpenStack API now and in the future, you will be using this container to create VMs, mount volumes, etc.

    A wrapper script `run.sh` is provided, which assumes that directories `bin/` and `ssh/` exist in the working directory, and that `bin/` contains `openrc.sh`:

    ```sh
    ./run.sh
    ```

    You can use this `run.sh` script as a template for you to parameterize, perhaps for alternative `openrc.sh` files.

2.  Create ssh Keys (Do This Once)

    This step of ssh key generation is important. In our experience, we have not had good luck with preexisting keys. You may have to generate a new one. Be careful with the `-f` argument below. We are operating under one allocation so make sure your key names do not collide with other users. Name your key something like `<some short somewhat unique id>-${OS_PROJECT_NAME}-api-key`. Then you add your public key the TACC dashboard with `openstack keypair create`.

    ```sh
    cd ~/.ssh
    ssh-keygen -b 2048 -t rsa -f <key-name> -P ""
    openstack keypair create --public-key <key-name>.pub <key-name>
    # go back to home directory
    cd
    ```

    The `ssh` directory was mounted from outside the Docker container you are currently running. Your public/private key should be saved there. Don't lose it or else you may not be able to delete the VMs you are about to create.

3.  Testing Setup

    At this point, you should be able to run `openstack image list` which should yield something like:

    | ID                                   | Name                               |
    |------------------------------------ |---------------------------------- |
    | fd4bf587-39e6-4640-b459-96471c9edb5c | AutoDock Vina Launch at Boot       |
    | 02217ab0-3ee0-444e-b16e-8fbdae4ed33f | AutoDock Vina with ChemBridge Data |
    | b40b2ef5-23e9-4305-8372-35e891e55fc5 | BioLinux 8                         |

    If not, check your setup.


<a id="h-03303143"></a>

## Working with Jetstream API to Create VMs

At this point, we are past the hard work. You will employ the `unidata/xsede-jetstream` container accessed via the `openstack.sh` convenience script to

-   Create IP Numbers
-   Create VMs
-   Tear down VMs
-   Create Data Volumes
-   Attach Data Volumes

If you have not done so already:

```sh
./openstack.sh -o </path/to/your openrc.sh file> -s </path/to/your/ssh directory>
```


<a id="h-5E7A7E65"></a>

### IP Numbers

We are ready to fire up VMs. First create an IP number which we will be using shortly:

```sh
openstack floating ip create public
openstack floating ip list
```

or you can just `openstack floating ip list` if you have IP numbers left around from previous VMs.


<a id="h-EA17C2D9"></a>

### Boot VM

1.  Create VM

    Now you can boot up a VM with something like the following command:

    ```sh
    boot.sh -n unicloud -k <key-name> -s m1.medium -ip 149.165.157.137
    ```

    The `boot.sh` command takes a VM name, [ssh key name](#h-EE48476C) defined earlier, size, and IP number created earlier, and optionally an image UID which can be obtained with `openstack image list | grep -i featured`. Note that these feature VMs are recommended by Jetstream staff, and have a default user corresponding to the Linux distribution flavor. For example,

    ```sh
    $ openstack image list | grep -i featured
    ```

    may yield something like:

    ```sh
    | 4ada5750-4ba4-4cc6-8d12-9001fe04ae1b | JS-API-Featured-Centos6-Feb-13-2018  |
    | 87df53d5-04bd-4bb8-862e-b67247f07f87 | JS-API-Featured-Centos7-Feb-13-2018  |
    | 20e6ec66-a5ec-41fc-820c-08a2af5bd1eb | JS-API-Featured-Ubuntu14-Feb-13-2018 |
    | a2c80fbf-2875-457a-b488-28c4afeb296b | JS-API-Featured-Ubuntu16-Feb-13-2018 |
    ```

    The CentOS VMs will have a default of user `centos` and the Ubuntu VMs will have a default user of `ubuntu`.

    Also see `boot.sh -h` and `openstack flavor list` for more information.

2.  SSH Into New VM

    At this point, you can `ssh` into our newly minted VM. Explicitly providing the key name with the `ssh` `-i` argument and a user name (e.g., `ubuntu` or `centos`) may be important:

    ```sh
    ssh -i ~/.ssh/<key-name> ubuntu@149.165.157.137
    ```

    At this point, you might see

    ```sh
    ssh: connect to host 149.165.157.137 port 22: No route to host
    ```

    Usually waiting for a few minutes resolves the issue. If you are still have trouble, try `openstack server stop <vm-uid-number>` followed by `openstack server start <vm-uid-number>`.

3.  Adding Additional SSH Keys (Optional)

    Once you are in your VM, it is probably best to add additional ssh public keys into the `authorized_keys` file to make logging in easier from whatever host you are connecting from.


<a id="h-9BEEAB97"></a>

### Create and Attach Data Volumes

You can create data volumes via the OpenStack API. As an example, here, we will be creating a 750GB `data` volume. You will subsequently attach the data volume:

```sh
openstack volume create --size 750 data

openstack volume list && openstack server list

openstack server add volume <vm-uid-number> <volume-uid-number>
```

You will then be able to log in to your VM and mount your data volume with typical Unix `mount`, `umount`, and `df` commands. If running these command manually (not using the `mount.sh` script) you will need to run `kfs.ext4 /dev/sdb` to create an `ext4` partition using the entire disk.

There is a `mount.sh` convenience script to mount **uninitialized** data volumes. Run this script as root or `sudo` on the newly created VM not from the OpenStack CL.

1.  Ensure Volume Availability Upon Machine Restart

    You want to ensure data volumes are available when the VM starts (for example after a reboot). To achieve this objective, you can run this command which will add an entry to the `/etc/fstab` file:

    ```shell
    echo UUID=2c571c6b-c190-49bb-b13f-392e984a4f7e /data ext4 defaults 1 1 | tee \
        --append /etc/fstab > /dev/null
    ```

    where the `UUID` represents the ID of the data volume device name (e.g., `/dev/sdb`) which you can discover with the `blkid` (or `ls -la /dev/disk/by-uuid`) command. [askubuntu](https://askubuntu.com/questions/164926/how-to-make-partitions-mount-at-startup-in-ubuntu-12-04) has a good discussion on this topic.


<a id="h-D6B1D4C2"></a>

### Opening TCP Ports

Opening TCP ports on VMs must be done via OpenStack with the `openstack security group` command line interfaces. In addition, this can be For example, to create a security group that will enable the opening of TCP port `80`:

```sh
secgroup.sh -n my-vm-ports -p 80
```

Once the security group is created, you can attach multiple TCP ports to that security group with `openstack security group` commands. For example, here we are attaching port `8080` to the `global-my-vm-ports` security group.

```sh
openstack security group rule create global-my-vm-ports --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0
```

Finally, you can attach the security group to the VM (e.g., `my-vm`) with:

```sh
openstack server add security group my-vm global-my-vm-ports
```


<a id="h-1B38941F"></a>

### Tearing Down VMs

1.  umount External Volumes

    There is also a `teardown.sh` convenience script for deleting VMs. Be sure to `umount` any data volumes before deleting a VM. For example on the VM in question,

    ```sh
    umount /data
    ```

    You may have to verify, here, that nothing is writing to that data volume such as Docker or NFS (e.g., `docker-compose stop`, `sudo service nfs-kernel-server stop`), in case you get errors about the volume being busy.

    In addition, just to be on the safe side, remove the volume from the VM via OpenStack:

    ```sh
    openstack volume list && openstack server list

    openstack server remove volume <vm-uid-number> <volume-uid-number>
    ```

2.  Tear Down

    Then finally from the OpenStack CL,

    ```sh
    teardown.sh -n unicloud -ip 149.165.157.137
    ```

    For now, you have to supply the IP number even though the script should theoretically be smart enough to figure that out.


<a id="h-56B1F4AC"></a>

### Swapping VMs

Cloud-computing promotes the notion of the throwaway VM. We can swap in VMs that will have the same IP address and attached volume disk storage. However, before swapping out VMs, we should do a bit of homework and careful preparation so that the swap can go as smoothly as possible.

1.  Prerequisites

    Create the VM that will be swapped in. Make sure to:

    -   [initialize new VM](../vm-init-readme.md)
    -   build or fetch relevant Docker containers
    -   copy over the relevant configuration files. E.g., check with `git diff` and scrutinize `~/config`
    -   check the crontab with `crontab -l`
    -   beware of any `10.0` address changes that need to be made (e.g., NFS mounts)
    -   consider other ancillary stuff (e.g., check home directory, `docker-compose` files)
    -   think before you type

2.  /etc/fstab and umount

    Examine `/etc/fstab` to find all relevant mounts on "old" VM. Copy over `fstab` to new host (the `UUIDs` should remain the same but double check). Then `umount` mounts.

3.  OpenStack Swap

    From the OpenStack command line, identify the VM IDs of the old and new VM as well as any attached external volume ID:

    ```shell
    openstack volume list && openstack server list
    ```

    Then swap out both the IP address as well as zero or more external data volumes with the new server.

    ```shell

    openstack server remove floating ip ${VM_ID_OLD} ${IP}
    openstack server add floating ip ${VM_ID_NEW} ${IP}

    for i in ${VOLUME_IDS}
    do
         openstack server remove volume ${VM_ID_OLD} $i
         openstack server add volume ${VM_ID_NEW} $i
    done
    ```

4.  /etc/fstab and mount

    Issue `blkid` (or `ls -la /dev/disk/by-uuid`) command to find `UUIDs` that will be inserted into the `/etc/fstab`. Lastly, `mount -a`.


<a id="h-DA34BC11"></a>

## Building a Kubernetes Cluster

It is possible to create a Kubernetes cluster with the Docker container described here. We employ [Andrea Zonca's modification of the kubespray project](https://github.com/zonca/jetstream_kubespray). Andrea's recipe to build a Kubernetes cluster on Jetstream with kubespray is described [here](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html). These instructions have been codified with the `kube-setup.sh` and `kube-setup2.sh` scripts.

Make sure to run both `kubectl` and `helm` from the client and `ssh` tunnel (`ssh ubuntu@FLOATINGIPOFMASTER -L 6443:localhost:6443`)into the master node as described in the instructions.


<a id="h-F44D1317"></a>

### Define cluster with cluster.tf

First, modify `~/jetstream_kubespray/inventory/zonca/cluster.tf` to specify the number of nodes in the cluster and the size ([flavor](#h-958EA909)) of the VMs. For example,

```sh
# nodes
number_of_k8s_nodes = 0
number_of_k8s_nodes_no_floating_ip = 2
flavor_k8s_node = "4"
```

will create a 2 node cluster of `m1.large` VMs. [See Andrea's instructions for more details](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html).

[This spreadsheet](https://docs.google.com/spreadsheets/d/15qngBz4L5gwv_JX9HlHsD4iT25Odam09qG3JzNNbdl8/edit?usp=sharing) will help you determine the size of the cluster based on number of users, desired cpu/user, desired RAM/user. Duplicate it and adjust it for your purposes.

`openstack flavor list` will give the IDs of the desired VM size.

Also, note that `cluster.tf` assumes you are building a cluster at the TACC data center with the sections pertaining to IU commented out. If you would like to set up a cluster at IU, make the necessary modifications located at the end of `cluster.tf`.

**IMPORTANT**: once you define an `image` (e.g., `image = JS-API-Featured-Ubuntu18-May-22-2019`) or a flavor size (e.g., `flavor_k8s_master = 2`), make sure you do not subsequently change it after you have run Terraform and Ansible! This scenario can happen when [adding cluster nodes](#h-1991828D) and the featured image no longer exists because it has been updated. If you must change these values, you'll first have to [preserve your application data](../vms/jupyter/readme.md#h-5F2AA05F) and do a [gentle - IP preserving - cluster tear down](#h-DABDACC7) before rebuilding it and re-installing your application.


<a id="h-0C658E7B"></a>

### Create VMs with kube-setup.sh

At this point, to create the VMs that will house the kubernetes cluster (named "k8s-unidata", for example) run

`kube-setup.sh -n k8s-unidata`

This script essentially wraps Terraform install scripts to launch the VMs according to `cluster.tf`.

Once, the script is complete, let the VMs settle for a while (let's say ten minutes). Behind the scenes `dpkg` is running on the newly created VMs which can take some time to complete.

1.  Check Status of VMs

    Check to see the status of the VMs with:

    ```sh
    openstack server list | grep k8s-unidata
    ```

    and

    ```sh
    watch -n 15 \
         ansible -i $HOME/jetstream_kubespray/inventory/k8s-unidata/hosts -m ping all
    ```

    1.  Steps if VMs are Unhappy

        If the check status process did not go smoothly, here are some thing you can try to remedy the problem.

        If you see any errors, you can try to wait a bit more or reboot the offending VM with:

        ```sh
        openstack server reboot <vm>
        ```

        or you can reboot all VMs with:

        ```sh
        osl | grep k8s-unidata | awk '{print $2}' | xargs -n1 openstack server reboot
        ```

        If VMs stuck in `ERROR` state. You may be able to fix this problem with:

        ```sh
        cd ~/jetstream_kubespray/inventory/k8s-unidata/
        CLUSTER=k8s-unidata bash -c 'sh terraform_apply.sh'
        ```

        or you can destroy the VMs and try again

        ```sh
        cd ~/jetstream_kubespray/inventory/k8s-unidata/
        CLUSTER=k8s-unidata bash -c 'sh terraform_destroy.sh'
        ```


<a id="h-05F9D0A2"></a>

### Install Kubernetes with kube-setup2.sh

Next, run

```sh
kube-setup2.sh -n k8s-unidata
```

If seeing errors related to `dpkg`, wait and try again or [try these steps](#h-F4401658).

Run `kube-setup2.sh -n k8s-unidata` again.


<a id="h-D833684A"></a>

### Check Cluster

Ensure the Kubernetes cluster is running:

```
kubectl get pods --all-namespaces
```

and get a list of the nodes:

```sh
kubectl get nodes --all-namespaces
```


<a id="h-1991828D"></a>

### Adding Nodes to Cluster

You can augment the computational capacity of your cluster by adding nodes. In theory, this is just a simple matter of [adding worker nodes](#h-F44D1317) in `jetstream_kubespray/inventory/k8s-unidata/cluster.tf` followed by running:

```sh
cd ~/jetstream_kubespray/inventory/k8s-unidata/
CLUSTER=k8s-unidata bash -c 'sh terraform_apply.sh'
```

Wait a bit to allow `dpkg` to finish running on the new node(s). [Check the VMS](#h-136A4851). Next:

```sh
cd ~/jetstream_kubespray
CLUSTER=k8s-unidata bash -c 'sh k8s_scale.sh'
```

[Check the cluster](#h-D833684A).


<a id="h-0324031E"></a>

### Removing Nodes from Cluster

It is also possible to remove nodes from a Kubernetes cluster. First see what nodes are running:

```sh
kubectl get nodes --all-namespaces
```

which will yield something like:

```sh
NAME                     STATUS   ROLES    AGE   VERSION
k8s-unidata-k8s-master-1    Ready    master   42h   v1.12.5
k8s-unidata-k8s-node-nf-1   Ready    node     42h   v1.12.5
k8s-unidata-k8s-node-nf-2   Ready    node     41h   v1.12.5
```

From the Kubernetes master node:

```sh
cd ~/jetstream_kubespray
CLUSTER=k8s-unidata bash -c 'sh k8s_remove_node.sh k8s-unidata-k8s-node-nf-2'
```

followed by running:

```sh
teardown.sh -n  k8s-unidata-k8s-node-nf-2
```

from the openstack command line.

[Check the cluster](#h-D833684A).


<a id="h-DABDACC7"></a>

### Tearing Down the Cluster

1.  Without Preserving IP of Master Node

    Once you are finished with your Kubernetes cluster you can completely wipe it out (think before you type and make sure you have the cluster name correct):

    ```sh
    cd ~/jetstream_kubespray/inventory/k8s-unidata/
    CLUSTER=k8s-unidata bash -c 'sh terraform_destroy.sh'
    ```

2.  With Preserving IP of Master Node

    You can also tear down your cluster but still preserve the IP number of the master node. This is useful and important when the IP of the master node is associated with a DNS name that you wish to keep associated.

    ```sh
    cd ~/jetstream_kubespray/inventory/k8s-unidata/
    CLUSTER=k8s-unidata bash -c 'sh terraform_destroy_keep_floatingip.sh'
    ```

    Subsequently, when you invoke `terraform_apply.sh`, the master node should have the same IP number as before.

    **Note**: AFTER invoking `terraform_apply.sh` remove the `~/.ssh/known_hosts` line that corresponds to the old master node! This can easily be achieved by sshing into the new master node which will indicate the offending line in `~/.ssh/known_hosts`. This will avoid headaches when invoking `kube-setup2.sh`.


<a id="h-005364BF"></a>

### Monitoring the Cluster with Grafana and Prometheus

[Grafana](https://grafana.com/) is a monitoring engine equipped with nice dashboards and fancy time-series visualizations. [Prometheus](https://github.com/camilb/prometheus-kubernetes) allows for monitoring of Kubernetes clusters.

Installing these monitoring technologies is fairly straightforward and [described here](https://zonca.github.io/2019/04/kubernetes-monitoring-prometheus-grafana.html).


<a id="h-78283D4A"></a>

# Appendix


<a id="h-958EA909"></a>

## Jetstream VM Flavors

| ID | Name       | RAM(GB) | Disk(GB) | VCPUs |
|--- |---------- |------- |-------- |----- |
| 1  | m1.tiny    | 2       | 8        | 1     |
| 2  | m1.small   | 4       | 20       | 2     |
| 3  | m1.medium  | 16      | 60       | 6     |
| 4  | m1.large   | 30      | 60       | 10    |
| 5  | m1.xlarge  | 60      | 60       | 24    |
| 6  | m1.xxlarge | 120     | 60       | 44    |
| 14 | s1.large   | 30      | 120      | 10    |
| 15 | s1.xlarge  | 60      | 240      | 24    |
| 16 | s1.xxlarge | 120     | 480      | 44    |
