- [Establishing an NFS Mount from Wrangler to Jetstream VMs](#h:6F2C5533)
  - [Introduction](#h:21834535)
  - [Prerequisites](#h:F402F677)
  - [Attaching the unidata-wrangler Network onto Your VM](#h:4295622E)
  - [Opening NFS Related Ports](#h:86EAF003)
    - [Create the Wrangler Security Group](#h:C3E31F14)
    - [Attach Wrangler Security Group to VM](#h:FE477C60)
  - [Additional Networking Setup On VM](#h:8CC1C481)
    - [rpcbind](#h:4F9D6A34)
    - [ifconfig](#h:BF5FABB7)
    - [/etc/network/interfaces](#h:95D34D99)
    - [/etc/udev/rules.d/70-persistent-net.rules](#h:C4236EE6)
    - [ifup](#h:2188C4A9)
  - [Mounting Wrangler](#h:26D0062F)
  - [Ensure Volume Availability Upon Machine Restart](#h:D458816F)



<a id="h:6F2C5533"></a>

# Establishing an NFS Mount from Wrangler to Jetstream VMs


<a id="h:21834535"></a>

## Introduction

Wrangler is an XSEDE data storage system available both at TACC and IU. Unidata has a sizable disk storage allocation on Wrangler. This document describes how to establish an NFS Mount from Wrangler to a Jetstream VM.

These instructions assume an Ubuntu VM. In the future, we will have a similar document for CentOS.


<a id="h:F402F677"></a>

## Prerequisites

Setup the VM in [the usual manner](https://github.com/Unidata/xsede-jetstream/blob/master/vm-init-readme.md).

The Jetstream team will have to establish an OpenStack network to open a pipe between Wrangler and Jetstream. Email `help@xsede.org` to obtain this network. The `unidata-wrangler` network has already been setup for us at Indiana University:

```shell
$ openstack network list
+--------------------------------------+----------------------+--------------------------------------+
| ID                                   | Name                 | Subnets                              |
+--------------------------------------+----------------------+--------------------------------------+
| 52839426-7790-47ed-b3ef-49392ef78db2 | TG-ATM160027-api-net | cd29aa4e-665c-47df-9db1-569e64a7e0d9 |
| a180e538-acac-42cc-bdfa-ab93d068af0b | nexus-network        | ec0763bf-eca3-4df5-82e1-5085810664d1 |
| a2333b6e-06c5-4a66-9e41-86aa8a961ec0 | unidata-wrangler     | 12006371-87bf-46f6-8829-c907badc369c |
+--------------------------------------+----------------------+--------------------------------------+
```


<a id="h:4295622E"></a>

## Attaching the unidata-wrangler Network onto Your VM

To establish the NFS mount, you first have to attach the `unidata-wrangler` network to the VM in question from the OpenStack command line:

```shell

openstack server add network ${VM_ID} ${NIC_ID}
```

the result will look something like this:

```shell
$ openstack server list
+--------------------------------------+--------------------------------+---------+-----------------------------------------------------------------------------+
| ID                                   | Name                           | Status  | Networks                                                                    |
+--------------------------------------+--------------------------------+---------+-----------------------------------------------------------------------------+
| c9529c6c-c4a4-4633-83dc-f3894dbf0027 | TG-ATM160027-jupyterhub        | ACTIVE  | TG-ATM160027-api-net=10.0.0.24, 149.165.168.31; unidata-wrangler=10.5.0.107 |
+--------------------------------------+--------------------------------+---------+-----------------------------------------------------------------------------+
```


<a id="h:86EAF003"></a>

## Opening NFS Related Ports

Next you must open a series of NFS related ports both TCP and UDP: `111`, `875`, `892`, `2049`, `10053`, `32803`. To be on the safe side, limit those ports to the to the Wrangler IP (`149.165.238.47`).


<a id="h:C3E31F14"></a>

### Create the Wrangler Security Group

Create a Wrangler security group that we can subsequently re-use. Do this once.

```shell

openstack security group create --description "wrangler & icmp enabled" wrangler

WRANGLER_IP=149.165.238.47

for i in 111 875 892 2049 10053 32803
do
    openstack security group rule create wrangler --protocol tcp \
              --dst-port $i:$i --remote-ip ${WRANGLER_IP}
    openstack security group rule create wrangler --protocol udp \
              --dst-port $i:$i --remote-ip ${WRANGLER_IP}
done

openstack security group rule create wrangler --protocol icmp
```


<a id="h:FE477C60"></a>

### Attach Wrangler Security Group to VM

From the OpenStack command line, attach the `wrangler` security group to the VM.

```shell
openstack server add security group ${VM_ID} wrangler
```


<a id="h:8CC1C481"></a>

## Additional Networking Setup On VM


<a id="h:4F9D6A34"></a>

### rpcbind

The `rpcbind` IP is provided by the Jetstream team when they set up the VPN. It will always be a static IP number assuming we are using the same Wrangler mount point. For all intents and purposes, for `unidata-wrangler` network, it will be `10.5.0.96/28`. Login to the VM in question and as `sudo`:

```shell
echo rpcbind : 10.5.0.96/28 127.0.0.1 | tee --append /etc/hosts.allow > /dev/null
```


<a id="h:BF5FABB7"></a>

### ifconfig

At this point, you have to add the correct network to `/etc/udev/rules.d/70-persistent-net.rules` and `/etc/network/interfaces`. To achieve this run `ifconfig -a` which will generate something like:

```shell
ens3      Link encap:Ethernet  HWaddr fa:16:3e:0c:70:6c
          inet addr:10.0.0.26  Bcast:10.0.0.255  Mask:255.255.255.0
          inet6 addr: fe80::f816:3eff:fe0c:706c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:4065 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2609 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:27781617 (27.7 MB)  TX bytes:210853 (210.8 KB)

ens4      Link encap:Ethernet  HWaddr fa:16:3e:10:af:8d
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:160 errors:0 dropped:0 overruns:0 frame:0
          TX packets:160 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:11840 (11.8 KB)  TX bytes:11840 (11.8 KB)
```

Examine the output of `ifconfig` and find the network that is not in `UP` state, in this case `ens4`.


<a id="h:95D34D99"></a>

### /etc/network/interfaces

As `sudo`, add the following snippet to `/etc/network/interfaces`:

```shell
cat <<EOF >> /etc/network/interfaces

# Wrangler network
auto ${ENS}
iface ${ENS} inet dhcp
EOF
```


<a id="h:C4236EE6"></a>

### /etc/udev/rules.d/70-persistent-net.rules

Again, as `sudo` user, add this bit to `/etc/udev/rules.d/70-persistent-net.rules`:

```shell
echo SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", \
     ATTR{address}==\"fa:16:3e:f8:cf:ea\", NAME=\"${ENS}\" \
    | tee --append /etc/udev/rules.d/70-persistent-net.rules > /dev/null
```


<a id="h:2188C4A9"></a>

### ifup

Finally issue:

```shell
ifup ${ENS}
```


<a id="h:26D0062F"></a>

## Mounting Wrangler

We are ready to mount our Wrangler data directory onto, say, `/wrangler`. First, create the mount point:

```shell
mkdir -p ${MOUNT}
```

Then mount:

```shell
mount -v -t nfs iuwrang-c111.uits.indiana.edu:/data/projects/G-818573 \
      ${MOUNT} -o rsize=131072,wsize=131072,timeo=300,hard,vers=3
```


<a id="h:D458816F"></a>

## Ensure Volume Availability Upon Machine Restart

You want to ensure data volumes are available when the VM starts (for example after a reboot). To achieve this objective, you can run this command which will add an entry to the `/etc/fstab` file:

```shell
echo iuwrang-c111.uits.indiana.edu:/data/projects/G-818573 ${MOUNT} \
     nfs rsize=131072,wsize=131072,timeo=300,hard,nofail \
    | tee --append /etc/fstab > /dev/null
```
