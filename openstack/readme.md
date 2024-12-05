- [Running VMs on Jetstream with OpenStack](#h-90A8A74D)
  - [Introduction](#h-11F59F95)
  - [Install Docker (Do This Once)](#h-DE5B47F1)
  - [Clone the science-gateway Repository (Do This Once)](#h-968FA51C)
  - [Pull or Build Docker Container (Do This Once)](#h-4A9632CC)
    - [Pull Container](#h-B5690030)
    - [Build Container](#h-1C54F677)
  - [API Setup](#h-CBD5EC54)
    - [Download and Edit openrc.sh (Do This Once)](#h-8B3E8EEE)
      - [[Reset your OpenStack TACC dashboard password](https://portal.tacc.utexas.edu/password-reset/)](#h-3E2185E5)
      - [Download your `openrc.sh` file from the IU (not TACC) dashboard at  <https://iu.jetstream-cloud.org> and move it to the `openstack/bin` directory.](#h-B34CC3AF)
      - [Edit `bin/openrc.sh` Password (Optional)](#h-9C0700C5)
    - [Fire Up Container and More Setup](#h-30B73273)
      - [openstack.sh](#h-5F4AFF6F)
      - [Create ssh Keys (Do This Once)](#h-EE48476C)
      - [Testing Setup](#h-257FBBBE)
  - [Working with Jetstream API to Create VMs](#h-03303143)
    - [IP Numbers](#h-5E7A7E65)
    - [Boot VM](#h-EA17C2D9)
      - [Create VM](#h-7E8034E7)
      - [SSH Into New VM](#h-10ACA1BC)
      - [Adding Additional SSH Keys (Optional)](#h-A66BED33)
    - [Create and Attach Data Volumes](#h-9BEEAB97)
      - [Ensure Volume Availability Upon Machine Restart](#h-F6AF5F18)
    - [Opening TCP Ports](#h-D6B1D4C2)
    - [Dynamic DNS and Recordsets](#h-612458CB)
    - [Tearing Down VMs](#h-1B38941F)
      - [umount External Volumes](#h-B367439E)
      - [Tear Down](#h-8FDA03F6)
    - [Swapping VMs](#h-56B1F4AC)
      - [Prerequisites](#h-82627F76)
      - [/etc/fstab and umount](#h-5122BD67)
      - [OpenStack Swap](#h-45D6670A)
      - [/etc/fstab and mount](#h-152E6DAB)
  - [Building a Kubernetes Cluster](#h-DA34BC11)
    - [Define cluster with cluster.tfvars](#h-F44D1317)
    - [Enable Dynamic DNS with cluster.tfvars](#h-7801DD3F)
    - [Create VMs with kube-setup.sh](#h-0C658E7B)
      - [Check Status of VMs](#h-136A4851)
        - [Ansible Timeouts](#h-2B239C73)
        - [Steps if VMs are Unhappy](#h-F4401658)
        - [Large Clusters with Many VMs](#h-E988560D)
        - [Broadcasting Commands With Ansible](#h-36DE33F4)
    - [Remove Bloat and Unneeded Software With remove-bloat.sh](#h-C54338F3)
    - [Install Kubernetes with kube-setup2.sh](#h-05F9D0A2)
    - [Tie up Loose Ends With kube-setup3.sh](#h-51612F75)
    - [Check Cluster](#h-D833684A)
    - [Adding Nodes to Cluster](#h-1991828D)
    - [Removing Nodes from Cluster](#h-0324031E)
    - [Sshing into Cluster Node](#h-6BB96836)
    - [Tearing Down the Cluster](#h-DABDACC7)
      - [Preparation](#h-325387C7)
      - [Without Preserving IP of Master Node](#h-25092B48)
      - [With Preserving IP of Master Node](#h-AA4B8849)
    - [Monitoring the Cluster with Grafana and Prometheus](#h-005364BF)
    - [Patching Master Node](#h-9BC6B08B)
    - [GPU Enabled Clusters](#h-7062BF9B)
- [Appendix](#h-78283D4A)
  - [Jetstream2 VM Flavors](#h-958EA909)



<a id="h-90A8A74D"></a>

# Running VMs on Jetstream with OpenStack


<a id="h-11F59F95"></a>

## Introduction

It is preferable to interface with the NSF Jetstream cloud via the [Atmosphere web interface](https://use.jetstream-cloud.org/application/dashboard). However, this web dashboard is limited in two important ways:

1.  Users cannot obtain VMs with static IPs
2.  Users cannot open low number ports (i.e., < `1024`) with the exception of ports `22`, `80` and `443` which are open by default.

If you are in either of these scenarios, you have to interface with Jetstream via the [OpenStack API](https://docs.jetstream-cloud.org/ui/cli/overview/). The problem here is that there is some initial setup which is somewhat painful but that you do only once. We provide a Docker container that hopefully eases some of the pain as it has the OpenStack command line tools and convenience scripts installed. After that setup, you can interface with the Jetstream OpenStack command line via the `openstack.sh` script which will launch a Docker container that will enable you to:

-   Create IP Numbers
-   Create VMs
-   Tear down VMs
-   Create Data Volumes
-   Attach Data Volumes
-   Open TCP ports

Note, you do not have to employ this Docker container. It is merely provided as a convenience. If you choose, you can go through the Jetstream OpenStack API instructions directly and ignore all that follows.


<a id="h-DE5B47F1"></a>

## Install Docker (Do This Once)

Install Docker via the `rocky-init.sh` script because we will be interacting with the OpenStack Jetstream API via Docker. This step should make our lives easier.


<a id="h-968FA51C"></a>

## Clone the science-gateway Repository (Do This Once)

We will be making heavy use of the `Unidata/science-gateway` git repository.

```sh
git clone https://github.com/Unidata/science-gateway
```


<a id="h-4A9632CC"></a>

## Pull or Build Docker Container (Do This Once)

```sh
cd science-gateway/openstack
```

At this point, you can either pull or build the `science-gateway` container:


<a id="h-B5690030"></a>

### Pull Container

```sh
docker pull unidata/science-gateway
```


<a id="h-1C54F677"></a>

### Build Container

```sh
docker build -t unidata/science-gateway .
```


<a id="h-CBD5EC54"></a>

## API Setup

We will be using the Jetstream API directly and via convenience scripts.


<a id="h-8B3E8EEE"></a>

### Download and Edit openrc.sh (Do This Once)

The next part involves downloading the `openrc.sh` file to work with our OpenStack allocation. You will have first login to the OpenStack TACC dashboard which will necessitate a password reset. Unfortunately, this login is not the same as the Jetstream Atmosphere web interface login. Also, follow the usual password advice of not reusing passwords as this password will end up in your OpenStack environment and [you may want to add it](#h-9C0700C5) in the `openrc.sh` file for convenience.


<a id="h-3E2185E5"></a>

#### [Reset your OpenStack TACC dashboard password](https://portal.tacc.utexas.edu/password-reset/)


<a id="h-B34CC3AF"></a>

#### Download your `openrc.sh` file from the IU (not TACC) dashboard at  <https://iu.jetstream-cloud.org> and move it to the `openstack/bin` directory.

-   See *"Use the Horizon dashboard to generate openrc.sh"* in the [Jetstream API instructions](https://docs.jetstream-cloud.org/ui/cli/openrc/).
-   From the [IU dashboard](https://iu.jetstream-cloud.org/project/api_access/), navigate to `Project`, `API Access`, then select `Download OpenStack RC File` at top-right.
-   Select **OpenStack RC File (Identity API 3)** , which will download as a script named something like `TG-ATM160027-openrc.sh`. You should rename it to `openrc.sh`.
-   Move this file to `bin/openrc.sh` (e.g., `/home/jane/science-gateway/openstack/bin/openrc.sh`).


<a id="h-9C0700C5"></a>

#### Edit `bin/openrc.sh` Password (Optional)

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


<a id="h-5F4AFF6F"></a>

#### openstack.sh

Start the `unidata/science-gateway` container with `openstack.sh` convenience script. The script take a `-o` argument for your `openrc.sh` file and a `-s` argument for the directory containing or will contain your ssh keys (e.g., `/home/jane/science-gateway/openstack/ssh` or a new directory that will contain contain your Jetstream OpenStack keys that we will be creating shortly). **Both arguments must be supplied with fully qualified path names.**

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


<a id="h-EE48476C"></a>

#### Create ssh Keys (Do This Once)

This step of ssh key generation is important. In our experience, we have not had good luck with preexisting keys. You may have to generate a new one. Be careful with the `-f` argument below. We are operating under one allocation so make sure your key names do not collide with other users. Name your key something like `<some short somewhat unique id>-${OS_PROJECT_NAME}-api-key`. Then you add your public key the TACC dashboard with `openstack keypair create`.

```sh
cd ~/.ssh
ssh-keygen -b 2048 -t rsa -f <key-name> -P ""
openstack keypair create --public-key <key-name>.pub <key-name>
# go back to home directory
cd
```

The `ssh` directory was mounted from outside the Docker container you are currently running. Your public/private key should be saved there. Don't lose it or else you may not be able to delete the VMs you are about to create.


<a id="h-257FBBBE"></a>

#### Testing Setup

At this point, you should be able to run `openstack image list` which should yield something like:

| ID                                   | Name                               |
|------------------------------------ |---------------------------------- |
| fd4bf587-39e6-4640-b459-96471c9edb5c | AutoDock Vina Launch at Boot       |
| 02217ab0-3ee0-444e-b16e-8fbdae4ed33f | AutoDock Vina with ChemBridge Data |
| b40b2ef5-23e9-4305-8372-35e891e55fc5 | BioLinux 8                         |

If not, check your setup.


<a id="h-03303143"></a>

## Working with Jetstream API to Create VMs

At this point, we are past the hard work. You will employ the `unidata/science-gateway` container accessed via the `openstack.sh` convenience script to

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


<a id="h-7E8034E7"></a>

#### Create VM

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
| 45405d78-e108-48bf-a502-14a0dab81915 | Featured-RockyLinux8 | active |
| e85293e8-c9b0-4fc9-88b6-e3645c7d1ad3 | Featured-Ubuntu18    | active |
| 49d5e275-23d6-44b5-aa60-94242d92caf1 | Featured-Ubuntu20    | active |
| e41dc578-b911-48c6-a468-e607a8b2c87c | Featured-Ubuntu22    | active |
```

The Rocky VMs will have a default of user `rocky` and the Ubuntu VMs will have a default user of `ubuntu`.

Also see `boot.sh -h` and `openstack flavor list` for more information.


<a id="h-10ACA1BC"></a>

#### SSH Into New VM

At this point, you can `ssh` into our newly minted VM. Explicitly providing the key name with the `ssh` `-i` argument and a user name (e.g., `rocky`) may be important:

```sh
ssh -i ~/.ssh/<key-name> rocky@149.165.157.137
```

At this point, you might see

```sh
ssh: connect to host 149.165.157.137 port 22: No route to host
```

Usually waiting for a few minutes resolves the issue. If you are still have trouble, try `openstack server stop <vm-uid-number>` followed by `openstack server start <vm-uid-number>`.


<a id="h-A66BED33"></a>

#### Adding Additional SSH Keys (Optional)

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


<a id="h-F6AF5F18"></a>

#### Ensure Volume Availability Upon Machine Restart

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


<a id="h-612458CB"></a>

### Dynamic DNS and Recordsets

JetStream2 handles dynamic DNS differently than JetStream1; domain names will look like `<instance-name>.<project-ID>.projects.jetstream-cloud.org`. In addition, domain names are assigned automatically when a floating IP is assigned to a VM which is on a network with the `dns-domain` property set.

To set this property when manually creating a network, run the following openstack command. Note the (necessary) trailing "." at the end of the domain:

`openstack network create <new-network-name> --dns-domain <project-ID>.projects.jetstream-cloud.org.`

To set this property on an existing network:

`openstack network set --dns-domain <project-ID>.projects.jetstream-cloud.org. <network-name>`

When creating a new VM using [boot.sh](./bin/boot.sh), the VM is added to the `unidata-public` network, which should already have the `dns_domain` property set. To confirm this for any network, run a:

`openstack network show <network>`

If you wanted to manually create/edit domain names, do so using the `openstack recordset` commands. Note that you must have `python-designateclient` [installed](https://docs.openstack.org/python-designateclient/latest/user/shell-v2.html).

```shell
# See the current state of your project's DNS zone
# Useful for getting IDs of individual recordsets
openstack recordset list <project-ID>.projects.jetstream-cloud.org.

# More closely inspect a given recordset
openstack recordset show <project-ID>.projects.jetstream-cloud.org. <recordset-ID>

# Create new DNS record
openstack recordset create \
  --record <floating-ip-of-instance> \
  --type A \
  <project-ID>.projects.jetstream-cloud.org. \
  <your-desired-hostname>.<project-ID>.projects.jetstream-cloud.org.

# Remove an unused record (because you created a new one for it, or otherwise)
openstack recordset delete <project-ID>.projects.jetstream-cloud.org. <old-recordset-ID>
```


<a id="h-1B38941F"></a>

### Tearing Down VMs


<a id="h-B367439E"></a>

#### umount External Volumes

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


<a id="h-8FDA03F6"></a>

#### Tear Down

Then finally from the OpenStack CL,

```sh
teardown.sh -n unicloud -ip 149.165.157.137
```

For now, you have to supply the IP number even though the script should theoretically be smart enough to figure that out.


<a id="h-56B1F4AC"></a>

### Swapping VMs

Cloud-computing promotes the notion of the throwaway VM. We can swap in VMs that will have the same IP address and attached volume disk storage. However, before swapping out VMs, we should do a bit of homework and careful preparation so that the swap can go as smoothly as possible.


<a id="h-82627F76"></a>

#### Prerequisites

Create the VM that will be swapped in. Make sure to:

-   initialize the new VM with the `rocky-init.sh` script
-   build or fetch relevant Docker containers
-   copy over the relevant configuration files. E.g., check with `git diff` and scrutinize `~/config`
-   check the crontab with `crontab -l`
-   beware of any `10.0` address changes that need to be made (e.g., NFS mounts)
-   consider other ancillary stuff (e.g., check home directory, `docker-compose` files)
-   think before you type


<a id="h-5122BD67"></a>

#### /etc/fstab and umount

Examine `/etc/fstab` to find all relevant mounts on "old" VM. Copy over `fstab` to new host (the `UUIDs` should remain the same but double check). Then `umount` mounts.


<a id="h-45D6670A"></a>

#### OpenStack Swap

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


<a id="h-152E6DAB"></a>

#### /etc/fstab and mount

Issue `blkid` (or `ls -la /dev/disk/by-uuid`) command to find `UUIDs` that will be inserted into the `/etc/fstab`. Lastly, `mount -a`.


<a id="h-DA34BC11"></a>

## Building a Kubernetes Cluster

It is possible to create a Kubernetes cluster with the Docker container described here. We employ [Andrea Zonca's modification of the kubespray project](https://github.com/zonca/jetstream_kubespray). Andrea's recipe to build a Kubernetes cluster on Jetstream with kubespray is described [here](https://zonca.dev/2022/03/kubernetes-jetstream2-kubespray.html). These instructions have been codified with the `kube-setup.sh` and `kube-setup2.sh` scripts.

Make sure to run both `kubectl` and `helm` from the client and `ssh` tunnel (`ssh ubuntu@$IP -L 6443:localhost:6443`) into the master node as described in the instructions.


<a id="h-F44D1317"></a>

### Define cluster with cluster.tfvars

First, set the `CLUSTER` name environment variable (named "k8s-unidata", for example) for the current shell and all processes started from the current shell. It will be referenced by various scripts. This step is done for you by supplying the `--name` argument to `jupyterhub.sh` and subsequently `z2j.sh` (see [here](../vms/jupyter/readme.md)). However, if you want to do this manually, run this from within the docker container launched by `jupyterhub.sh`:

```sh
export CLUSTER="$CLUSTER"
```

Then, modify `~/jetstream_kubespray/inventory/kubejetstream/cluster.tfvars` to specify the number of nodes in the cluster and the size ([flavor](#h-958EA909)) of the VMs. For example,

```sh
# nodes
number_of_k8s_nodes = 0
number_of_k8s_nodes_no_floating_ip = 2
flavor_k8s_node = "4"
```

will create a 2 node cluster of `m1.large` VMs. [See Andrea's instructions for more details](https://www.zonca.dev/posts/2022-03-30-jetstream2_kubernetes_kubespray.html).

[This spreadsheet](https://docs.google.com/spreadsheets/d/15qngBz4L5gwv_JX9HlHsD4iT25Odam09qG3JzNNbdl8/edit?usp=sharing) will help you determine the size of the cluster based on number of users, desired cpu/user, desired RAM/user. Duplicate it and adjust it for your purposes.

`openstack flavor list` will give the IDs of the desired VM size.

Also, note that `cluster.tfvars` assumes you are building a cluster at the TACC data center with the sections pertaining to IU commented out. If you would like to set up a cluster at IU, make the necessary modifications located at the end of `cluster.tfvars`.

**IMPORTANT**: once you define an `image` (e.g., `image = JS-API-Featured-Ubuntu18-May-22-2019`) or a flavor size (e.g., `flavor_k8s_master = 2`), make sure you do not subsequently change it after you have run Terraform and Ansible! This scenario can happen when [adding cluster nodes](#h-1991828D) and the featured image no longer exists because it has been updated. If you must change these values, you'll first have to [preserve your application data](../vms/jupyter/readme.md#h-5F2AA05F) and do a [gentle - IP preserving - cluster tear down](#h-DABDACC7) before rebuilding it and re-installing your application.


<a id="h-7801DD3F"></a>

### Enable Dynamic DNS with cluster.tfvars

JetStream2 handles dynamic DNS differently than JetStream1; domain names will look like `<instance-name>.<project-ID>.projects.jetstream-cloud.org`. In addition, domain names are assigned automatically when a floating IP is assigned to a VM which is on a network with the `dns-domain` property set.

To configure terraform to set this property, add/edit the line below in `cluster.tfvars`.

```shell
# Uncomment below and edit to set dns-domain network property
# network_dns_domain = "<project-ID>.projects.jetstream-cloud.org."
```

Note the (necessary) trailing "." at the end of the domain.

After running the terraform scripts (see the next section), you can ensure that the dns name was correctly assigned to your cluster's master node with:

```shell
nslookup <instance-name>.<project-ID>.projects.jetstream-cloud.org
```


<a id="h-0C658E7B"></a>

### Create VMs with kube-setup.sh

At this point, to create the VMs that will house the kubernetes cluster run

`kube-setup.sh`

This script essentially wraps Terraform install scripts to launch the VMs according to `cluster.tfvars`.

Once, the script is complete, let the VMs settle for a while (let's say ten minutes). Behind the scenes `dpkg` is running on the newly created VMs which can take some time to complete.


<a id="h-136A4851"></a>

#### Check Status of VMs

Check to see the status of the VMs with:

```sh
openstack server list | grep $CLUSTER
```

and

```sh
watch -n 15 \
     ansible -i $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts -m ping all
```


<a id="h-2B239C73"></a>

##### Ansible Timeouts

The ansible script works via `sudo`. That escalation can lead to timeout errors if `sudo` is not fast enough. For example:

```shell
fatal: [gpu-test3-1]: FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}
fatal: [gpu-test3-k8s-node-nf-1]: FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}
```

In that case add

```shell
timeout = 60
gather_timeout = 60
```

under the `[default]` tag in `jetstream_kubespray/ansible.cfg`.


<a id="h-F4401658"></a>

##### Steps if VMs are Unhappy

If the check status process did not go smoothly, here are some thing you can try to remedy the problem.

If you see any errors, you can try to wait a bit more or reboot the offending VM with:

```sh
openstack server reboot <vm>
```

or you can reboot all VMs with:

```sh
openstack server list | grep ${CLUSTER} | \ awk -F'|' '{print $2}' | \
    tr -d "[:blank:]"  | xargs -I {} -n1 openstack server reboot {}
```

If VMs stuck in `ERROR` state. You may be able to fix this problem with:

```sh
cd ~/jetstream_kubespray/inventory/$CLUSTER/
sh terraform_apply.sh
```

or you can destroy the VMs and try again

```sh
cd ~/jetstream_kubespray/inventory/$CLUSTER/
sh terraform_destroy.sh
```


<a id="h-E988560D"></a>

##### Large Clusters with Many VMs

In the event of deploying a large cluster with many VMs, during the invocation of the Ansible playbook, there will be parallel downloading of images from DockerHub. This will sometimes yield an error message saying that we reached our download limit of 100 anonymous downloads over six hours. In order to preempt this problem, modify `jetstream_kubespray/k8s_install.sh` and append `-e '{"download_run_once":true}'` i.e.,

```sh
ansible-playbook --become -i inventory/$CLUSTER/hosts cluster.yml -b -v --limit "${CLUSTER}*" -e '{"download_run_once":true}'
```

This modified command will be run in the next `kube-setup2.sh` step.

Also see [Large deployments of K8s](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/large-deployments.md).


<a id="h-36DE33F4"></a>

##### Broadcasting Commands With Ansible

With the help of Ansible, it is possible to "broadcast" a command to all VMs in a cluster. For example, to run the Unix `top` command on all VMs, you can:

```sh
ansible all --limit ${CLUSTER}* -m command -a "sh -c 'top -b -n 1 | head -n 9'" -i inventory/$CLUSTER/hosts
```

Theoretically, there is no need to `ssh` into each individual VM on a cluster to issue a command in the situation where you want a package installed, for example.


<a id="h-C54338F3"></a>

### Remove Bloat and Unneeded Software With remove-bloat.sh

Ubuntu VMs come with a lot of software and services that are unneeded for JupyterHub clusters (e.g., Firefox, CUPS, for printing services). The following commands with run a couple of ansible playbooks to perform some cleanup in that respect.

```sh
remove-bloat.sh
```


<a id="h-05F9D0A2"></a>

### Install Kubernetes with kube-setup2.sh

Next, run

```sh
kube-setup2.sh
```

If seeing errors related to `dpkg`, wait and try again or [try these steps](#h-F4401658).

Run `kube-setup2.sh` again.


<a id="h-51612F75"></a>

### Tie up Loose Ends With kube-setup3.sh

Next, run

```sh
kube-setup3.sh <optional email>
```

which ensures ssh keys are distributed on the cluster. Finally, it inserts an email address in files located `~/jupyterhub-deploy-kubernetes-jetstream/setup_https/` which will be [necessary later on for the retrieval letsencrypt SSL certificates](https://www.zonca.dev/posts/2023-09-26-https-kubernetes-letsencrypt).


<a id="h-D833684A"></a>

### Check Cluster

Ensure the Kubernetes cluster is running:

```
kubectl get pods -o wide --all-namespaces
```

and get a list of the nodes:

```sh
kubectl get nodes --all-namespaces
```


<a id="h-1991828D"></a>

### Adding Nodes to Cluster

! **THINK before you type here because if you scale with an updated Ubuntu VM ID with respect to what is running on the cluster, you may wipe out your cluster** ! [See the GitHub issue about this topic](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/issues/54). **Also**, the if adding many nodes, see section on [Large Clusters with Many VMs](#h-E988560D).

You can augment the computational capacity of your cluster by adding nodes. In theory, this is just a simple matter of [adding worker nodes](#h-F44D1317) in `jetstream_kubespray/inventory/$CLUSTER/cluster.tfvars` followed by running:

```sh
cd ~/jetstream_kubespray/inventory/$CLUSTER/
sh terraform_apply.sh
```

Wait a bit to allow `dpkg` to finish running on the new node(s). [Check the VMS](#h-136A4851). Next:

```sh
cd ~/jetstream_kubespray
sleep 1000; sh k8s_scale.sh
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

From the Kubernetes client:

```sh
cd ~/jetstream_kubespray
sh k8s_remove_node.sh k8s-unidata-k8s-node-nf-2
```

followed by running:

```sh
teardown.sh -n  k8s-unidata-k8s-node-nf-2
```

from the openstack command line.

If tearing down many nodes/VMs, you can try something like:

```sh
for i in {3..10}; do sh k8s_remove_node.sh k8s-unidata-k8s-node-nf-$i; done

for i in {3..10}; do teardown.sh -n k8s-unidata-k8s-node-nf-$i; done
```

[Check the cluster](#h-D833684A).

**Note**, you can make the tear down process go faster by not having `k8s_remove_node.sh` prompt you ever time it removes a node. This can be done by editing the `k8s_remove_node.sh` script and appending:

```sh
-e skip_confirmation=true
```

so that the script looks like:

```sh
ansible-playbook --become -i inventory/$CLUSTER/hosts remove-node.yml -b -v --extra-vars "node=$1" -e skip_confirmation=true
```


<a id="h-6BB96836"></a>

### Sshing into Cluster Node

It is occasionally necessary to jump on cluster worker nodes to install a package (e.g., `nfs-common`) or to investigate a problem. This can be easily accomplished with

```sh
ssh -J ubuntu@${IP} ubuntu@<worker-private-ip>
```

from the Kubernetes client machine.

A convenience function has been added to the `.bashrc` file included in the `science-gateway` docker image to quickly jump to worker node `N` without having to first query `kubectl get nodes -o wide` for the private IP.

Simply run `worker <N>` from within a cluster's associated control container to ssh jump from the main node of the cluster to the N'th worker node.


<a id="h-DABDACC7"></a>

### Tearing Down the Cluster


<a id="h-325387C7"></a>

#### Preparation

As a matter of due diligence and for future possible forensic analysis, you may have to capture the state of the main node VM by backing up the disk to an internal Unidata location (e.g., `fserv`). Work with Unidata system administrator staff to determine where that place should be. Use the `remote_sync_backup.sh` script from the Unidata host to save that information, e.g.,

```sh
./remote_sync_backup.sh ubuntu k8s-bsu-jhub /raid/share/jetstream/jupyterhub_backups
```


<a id="h-25092B48"></a>

#### Without Preserving IP of Master Node

Once you are finished with your Kubernetes cluster you can completely wipe it out (think before you type and make sure you have the cluster name correct):

```sh
cd ~/jetstream_kubespray/inventory/$CLUSTER/
sh terraform_destroy.sh
```


<a id="h-AA4B8849"></a>

#### With Preserving IP of Master Node

You can also tear down your cluster but still preserve the IP number of the master node. This is useful and important when the IP of the master node is associated with a DNS name that you wish to keep associated.

```sh
cd ~/jetstream_kubespray/inventory/$CLUSTER/
sh terraform_destroy_keep_floatingip.sh
```

Subsequently, when you invoke `terraform_apply.sh`, the master node should have the same IP number as before.

**Note**: AFTER invoking `terraform_apply.sh` remove the `~/.ssh/known_hosts` line that corresponds to the old master node! This can easily be achieved by sshing into the new master node which will indicate the offending line in `~/.ssh/known_hosts`. This will avoid headaches when invoking `kube-setup2.sh`.


<a id="h-005364BF"></a>

### Monitoring the Cluster with Grafana and Prometheus

[Grafana](https://grafana.com/) is a monitoring engine equipped with nice dashboards and fancy time-series visualizations. [Prometheus](https://github.com/camilb/prometheus-kubernetes) allows for monitoring of Kubernetes clusters.

Installing these monitoring technologies is fairly straightforward and [described here](https://www.zonca.dev/posts/2019-04-20-jetstream_kubernetes_monitoring.html).


<a id="h-9BC6B08B"></a>

### Patching Master Node

You'll want to keep the master node security patched as it will have a publicly accessible IP number attached to a well known DNS name. If you see packages out of date upon login, as root user:

```sh
 apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade \
     && apt autoremove -y
reboot -h now
```


<a id="h-7062BF9B"></a>

### GPU Enabled Clusters

In order to build a GPU enabled cluster, [refer to Andrea's documentation](https://www.zonca.dev/posts/2024-02-09-kubernetes-gpu-jetstream2).

Also, pay special attention to the `cluster.tfvars` to select VMs that have GPU hardware.


<a id="h-78283D4A"></a>

# Appendix


<a id="h-958EA909"></a>

## Jetstream2 VM Flavors

| ID | Name      | RAM     | Disk | VCPUs | Is Public |
| 1  | m3.tiny   | 3072    | 20   | 1     | True      |
| 10 | g3.small  | 15360   | 60   | 4     | False     |
| 11 | g3.medium | 30720   | 60   | 8     | False     |
| 12 | g3.large  | 61440   | 60   | 16    | False     |
| 13 | g3.xl     | 128000  | 60   | 32    | False     |
| 14 | r3.large  | 512000  | 60   | 64    | False     |
| 15 | r3.xl     | 1024000 | 60   | 128   | False     |
| 2  | m3.small  | 6144    | 20   | 2     | True      |
| 3  | m3.quad   | 15360   | 20   | 4     | True      |
| 4  | m3.medium | 30720   | 60   | 8     | True      |
| 5  | m3.large  | 61440   | 60   | 16    | True      |
| 7  | m3.xl     | 128000  | 60   | 32    | True      |
| 8  | m3.2xl    | 256000  | 60   | 64    | True      |
