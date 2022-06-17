- [Overview](#overview)
- [Initial Setup](#initialSetup)
	- [Create the VM](#createVM)
	- [Security Profile](#security)
	- [Clone the science-gateway Repository](#cloneSG)
	- [Install docker and docker compose](#docker)
	- [Edit /etc/fstab](#fstab)
		- [Format and mount WRF output volume](#fstab.wrf)
		- [Remove "software" Mount](#fstab.software)
		- [NFS Mount to idd-archiver Data](#fstab.nfs)
		- [Mount the Volumes](#fstab.mount)

<a id="overview"></a>
# Overview

The WRF VM on JetStream 2 is intended to perform automatic WRF model runs
initialized using model output data that is fetched by the `idd-archiver`
machine also found on JetStream2. WRF is ran within a Docker container and
output can be accessed from outside Unidata through a RAMADDA server running on
this same VM.

<a id="initialSetup"></a>
# Initial Setup

<a id="createVM"></a>
## Create the VM

Create an `m3.large` RockyLinux VM with the [Jetstream OpenStack
API](../../openstack/readme.md#h-03303143). We will also be creating and
attaching a [data volume](../../openstack/readme.md#h-9BEEAB97).

In a `unidata/science-gateway` container, create an IP and launch the VM with

```shell
openstack floating ip create public
boot.sh --name <server-name> --key <openstack-key-name> --size m3.large --ip <ip-from-previous-command> --image <rocky-image-id>
```

Create and attach the data volume that will be used for WRF ouput:

```shell
openstack volume create --size <size-in-GB> <volume-name>
openstack server add volume <server-name> <volume-name>
```

<a id="security"></a>
## Security Profile

`ssh` into the VM and apply the security profile as instructed by Unidata
sys-admin staff.

<a id="cloneSG"></a>
## Clone the science-gateway Repository

We will be making heavy use of the `Unidata/science-gateway` git repository.

```shell
git clone https://github.com/Unidata/science-gateway ~/science-gateway
```

<a id="docker"></a>
## Install docker and docker compose

Run `rocky-init.sh` to install `docker`, `docker-compose`, and other niceties,
as well as upgrade the system.

```shell
cd ~/science-gateway
sudo ./rocky-init.sh $USER
```

The VM will reboot after the script has finished executing. `ssh` back into the VM
and test `docker` and `docker-compose`.

```shell
docker --help
docker compose --help
```

<a id="fstab"></a>
## Edit /etc/fstab

<a id="fstab.wrf"></a>
### Format and mount WRF output volume

First, ensure the volume was attached with `ls /dev/sd*`. Typically, the data
volume will be found at `/dev/sdb`, although you can cross reference with the
output of the `openstack server add volume...` command from earlier.

Format the volume:

```shell
sudo mkfs.ext4 <path/to/dev>
```

Create the mount directory and change owner to allow the rocky user and docker
to access it:

```shell
sudo mkdir /wrfout
sudo chown -R rocky:docker /wrfout
```

Take note of the UUID of the newly formated volume with:

```shell
blkid
# if this does not show the UUID of the new volume, try running with sudo
sudo blkid
```

Add the following line to `/etc/fstab`

```
UUID=<UUID> /wrfout ext4 defaults 1 1
```

<a id="fstab.software"></a>
### Remove "software" Mount

Instances on JetStream2 come automounted with a `/software` directory provided
by JetStream staff that [contains shared
software](https://portal.xsede.org/jetstream2#usage:software). We don't need
this, so we unmount this volume:

```shell
sudo umount /software
```

To ensure this doesn't get remounted on reboot comment out the following line
(or something like it) in `/etc/fstab`:

```
#149.165.158.38:6789,149.165.158.22:6789,149.165.158.54:6789,149.165.158.70:6789,149.165.158.86:6789:/volumes/_nogroup/b7112570-f7cb-4bd2-8c0e-39b08609b9fd/01aa9d72-69bf-4250-9245-2eaddcdb251d /software ceph name=js2softwarero,secretfile=/etc/ceph.js2softwarero.secret,x-systemd.device-timeout=31,x-systemd.mount-timeout=30,noatime,_netdev,ro 0 0
```

<a id="fstab.nfs"></a>
### NFS Mount to idd-archiver Data

The [idd-archiver](../idd-archiver/readme.md) machine stores a five (5) day
archive of upstream data that feeds JetStream2 resources. The WRF will be
initialized with model data from this machine through an NFS mount on the `10.0`
network. On a `unidata/science-gateway` container, run `openstack server list`
to find the appropriate IP. Also, take note of the `10.0` IP of the WRF machine.
Add the following line to `/etc/fstab`, while ensuring you're using the
appropriate (idd-archiver) IP:

```
10.0.0.165:/data /data nfs rsize=32768,wsize=32768,timeo=14,intr
```

Create the mount point and change ownership:

```shell
sudo mkdir /data
sudo chown -R rocky:docker /data
```

*On the idd-archiver machine:*
 
To enable the WRF VM to connect to the `idd-archiver` machine, you must add the
WRF VM's `10.0` IP to the `/etc/exports` file.

```
/data 10.0.0.246(rw,sync,no_subtree_check)
```

To apply the changes to the `/etc/exports` file:

```shell
sudo exportfs -ra
```

<a id="fstab.mount"></a>
### Mount the Volumes

Mount the volumes found in `/etc/fstab` and inspect your work.

```shell
df -h
sudo mount -a
df -h
```
