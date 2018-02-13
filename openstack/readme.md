- [Running VMs on Jetstream with OpenStack](#h:90A8A74D)
  - [Introduction](#h:11F59F95)
  - [Install Docker (Do This Once)](#h:DE5B47F1)
  - [Clone the xsede-jetstream Repository (Do This Once)](#h:968FA51C)
  - [Pull or Build Docker Container (Do This Once)](#h:4A9632CC)
    - [Pull Container](#h:B5690030)
    - [Build Container](#h:1C54F677)
  - [API Setup](#h:CBD5EC54)
    - [Download and Edit openrc.sh (Do This Once)](#h:8B3E8EEE)
    - [Fire Up Container and More Setup](#h:30B73273)
  - [Working with Jetstream API to Create VMs](#h:03303143)
    - [IP Numbers](#h:5E7A7E65)
    - [Boot VM](#h:EA17C2D9)
    - [Create and Attach Data Volumes](#h:9BEEAB97)
    - [Opening TCP Ports](#h:D6B1D4C2)
    - [Tearing Down VMs](#h:1B38941F)



<a id="h:90A8A74D"></a>

# Running VMs on Jetstream with OpenStack


<a id="h:11F59F95"></a>

## Introduction

It is preferable to interface with the XSEDE Jetstream cloud via the [Atmosphere web interface](https://use.jetstream-cloud.org/application/dashboard). However, this web dashboard is limited in two important ways:

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


<a id="h:DE5B47F1"></a>

## Install Docker (Do This Once)

[Install Docker](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md) in your computing environment because we will be interacting with the OpenStack Jetstream API via Docker. This step should make our lives easier.


<a id="h:968FA51C"></a>

## Clone the xsede-jetstream Repository (Do This Once)

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```sh
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h:4A9632CC"></a>

## Pull or Build Docker Container (Do This Once)

```sh
cd xsede-jetstream/openstack
```

At this point, you can either pull or build the `xsede-jetstream` container:


<a id="h:B5690030"></a>

### Pull Container

```sh
docker pull unidata/xsede-jetstream
```


<a id="h:1C54F677"></a>

### Build Container

```sh
docker build -t unidata/xsede-jetstream .
```


<a id="h:CBD5EC54"></a>

## API Setup

We will be using the Jetstream API directly and via convenience scripts.


<a id="h:8B3E8EEE"></a>

### Download and Edit openrc.sh (Do This Once)

The next part involves downloading the `openrc.sh` file to work with our OpenStack allocation. You will have first login to the OpenStack TACC dashboard which will necessitate a password reset. Unfortunately, this login is not the same as the Jetstream Atmosphere web interface login. Also, follow the usual password advice of not reusing passwords as this password will end up in your OpenStack environment and [you may want to add it](#h:9C0700C5) in the `openrc.sh` file for convenience.

1.  [Reset your OpenStack TACC dashboard password](https://portal.tacc.utexas.edu/password-reset/).

2.  Download your `openrc.sh` file from the IU (not TACC) dashboard at <https://iu.jetstream-cloud.org> and move it to the `openstack` directory.
    
    * See *"Use the Horizon dashboard to generate openrc.sh"* in the [Jetstream API instructions](https://iujetstream.atlassian.net/wiki/display/JWT/Setting+up+openrc.sh).
    
    * From the [IU dashboard](https://iu.jetstream-cloud.org/project/api_access/), navigate to `Project`, `API Access`, then select `Download OpenStack RC File` at top-right.
    
    * Select **OpenStack RC File (Identity API 3)** , which will download as a script named something like `TG-ATM160027-openrc.sh`. You should rename it to `openrc.sh`.
    
    * Move this file to `openrc.sh` (e.g., `/home/jane/xsede-jetstream/openstack/openrc.sh`).

3.  Edit `openrc.sh` Password (Optional)

    For convenience, you may wish to add your password to the `openrc.sh` file. Again, follow the usual advice of not reusing passwords as this password will end up in your OpenStack environment.

    Edit the `openrc.sh` file and the supply the TACC resource `OS_PASSWORD` you [reset earlier](#h:8B3E8EEE):

    ```sh
    export OS_PASSWORD="changeme!"
    ```

    Comment out

    ```sh
    # echo "Please enter your OpenStack Password: "
    # read -sr OS_PASSWORD_INPUT
    ```


<a id="h:30B73273"></a>

### Fire Up Container and More Setup

1.  openstack.sh

    Start the `unidata/xsede-jetstream` container with `openstack.sh` convenience script. The script take a `-o` argument for your `openrc.sh` file and a `-s` argument for the directory containing or will contain your ssh keys (e.g., `/home/jane/xsede-jetstream/openstack/ssh` or a new directory that will contain contain your Jetstream OpenStack keys that we will be creating shortly). **Both arguments must be supplied with fully qualified path names.**

    ```sh
    chmod +x openstack.sh
    ./openstack.sh -o </path/to/your openrc.sh file> -s </path/to/your/ssh directory>
    ```

    Subsequently, when interacting with Jetstream via OpenStack API now and in the future, you will be using this container to create VMs, mount volumes, etc.

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

    At this point, you should be able to run `glance image-list` which should yield something like:

    | ID                                   | Name                               |
    |------------------------------------ |---------------------------------- |
    | fd4bf587-39e6-4640-b459-96471c9edb5c | AutoDock Vina Launch at Boot       |
    | 02217ab0-3ee0-444e-b16e-8fbdae4ed33f | AutoDock Vina with ChemBridge Data |
    | b40b2ef5-23e9-4305-8372-35e891e55fc5 | BioLinux 8                         |

    If not, check your setup.


<a id="h:03303143"></a>

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


<a id="h:5E7A7E65"></a>

### IP Numbers

We are ready to fire up VMs. First create an IP number which we will be using shortly:

```sh
openstack floating ip create public
openstack floating ip list
```

or you can just `openstack floating ip list` if you have IP numbers left around from previous VMs.


<a id="h:EA17C2D9"></a>

### Boot VM

1.  Create VM

    Now you can boot up a VM with something like the following command:

    ```sh
    boot.sh -n unicloud -k <key-name> -s m1.medium -ip 149.165.157.137
    ```

    The `boot.sh` command takes a VM name, [ssh key name](#h:EE48476C) defined earlier, size, and IP number created earlier, and optionally an image UID which can be obtained with `glance image-list | grep -i featured`. See `boot.sh -h` and `openstack flavor list` for more information.

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


<a id="h:9BEEAB97"></a>

### Create and Attach Data Volumes

You can create data volumes via the OpenStack API. As an example, here, we will be creating a 750GB `data` volume. You will subsequently attach the data volume:

```sh
openstack volume create --size 750 data

openstack volume list && openstack server list

openstack server add volume <vm-uid-number> <volume-uid-number>
```

You will then be able to log in to your VM and mount your data volume with typical Unix `mount`, `umount`, and `df` commands.  If running these command manually (not using the `mount.sh` script) you will need to run `kfs.ext4 /dev/sdb` to create an ext4 partition using the entire disk.

There is a `mount.sh` convenience script to mount **uninitialized** data volumes. Run this script as root or sudo on the newly created VM not from the OpenStack CL.

1.  Ensure Volume Availability Upon Machine Restart

    You want to ensure data volumes are available when the VM starts (for example after a reboot). To achieve this objective, you can run this command which will add an entry to the `/etc/fstab` file:

    ```shell
    echo UUID=2c571c6b-c190-49bb-b13f-392e984a4f7e /data ext4 defaults 1 1 | tee \
        --append /etc/fstab > /dev/null
    ```

    where the `UUID` represents the ID of the data volume device name (e.g., `/dev/sdb`) which you can discover with the `blkid` command. [askubuntu](https://askubuntu.com/questions/164926/how-to-make-partitions-mount-at-startup-in-ubuntu-12-04) has a good discussion on this topic.


<a id="h:D6B1D4C2"></a>

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


<a id="h:1B38941F"></a>

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
