- [Running VMs on Jetstream with OpenStack](#h:90A8A74D)
  - [Install Docker](#h:DE5B47F1)
  - [Clone the xsede-jetstream Repository](#h:968FA51C)
  - [Pull or Build Docker Container](#h:4A9632CC)
    - [Pull Container](#h:B5690030)
    - [Build Container](#h:1C54F677)
  - [API Setup](#h:CBD5EC54)
    - [openrc.sh](#h:8B3E8EEE)
    - [Fire Up Container and More Setup](#h:30B73273)
  - [Working with Jetstream API to Create VMs](#h:03303143)
    - [IP Numbers](#h:5E7A7E65)
    - [Boot VM](#h:EA17C2D9)
    - [Create and Attach Data Volumes](#h:9BEEAB97)
    - [ssh Into New VM](#h:D961F6F8)



<a id="h:90A8A74D"></a>

# Running VMs on Jetstream with OpenStack


<a id="h:DE5B47F1"></a>

## Install Docker

[Install Docker](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md) in your computing environment because we will be interacting with the OpenStack Jetstream API via Docker. This step should make our lives easier.


<a id="h:968FA51C"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```sh
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h:4A9632CC"></a>

## Pull or Build Docker Container

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

### openrc.sh

The next part involves downloading the `openrc.sh` file to work with our OpenStack allocation. You will have first login to the OpenStack TACC dashboard which will necessitate a password reset. Unfortunately, this login is not the same as the Jetstream Atmosphere web interface login. Also, follow the usual password advice of not reusing passwords as this password will end up in your OpenStack environment and [you may want to add it](#h:9C0700C5) in the `openrc.sh` file for convenience.

1.  Resetting Password

    [Reset your OpenStack TACC dashboard password](https://portal.tacc.utexas.edu/password-reset/).

2.  Download openrc.sh

    Download the `openrc.sh` file [according to the Jetstream API instructions](https://iujetstream.atlassian.net/wiki/display/JWT/Setting+up+openrc.sh). See "Use the Horizon dashboard to generate openrc.sh". Use the IU: <https://jblb.jetstream-cloud.org/dashboard> not the TACC dashboard. In the Jetstream Dashboard, navigate to `Access & Security`, `API Access` to download `openrc.sh` (v3). (In reality, it will be named something like `TG-ATM160027-openrc.sh`. You can rename it to `openrc.sh`, if you want.)

3.  Edit openrc.sh Password (Optional)

    Optionally, for convenience, you may wish to add your password to the `openrc.sh` file. Again, follow the usual advice of not reusing passwords as this password will end up in your OpenStack environment.
    
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

    Start the `unidata/xsede-jetstream` container with `openstack.sh` convenience script. The script take a `-o` argument for your `openrc.sh` file and a `-s` argument for the directory containing or will contain your ssh keys (e.g., `~/.ssh` or a new directory that will contain contain your Jetstream OpenStack keys that we will be creating shortly).
    
    ```sh
    chmod +x openstack.sh
    ./openstack.sh -o <your openrc.sh file> -s <.ssh dir>
    ```

2.  Create ssh Keys

    Do this step once. This step of ssh key generation is important. In our experience, we have not had good luck with pre-existing keys. You may have to generate a new one. Be careful with the `-f` argument below. We are operating under one allocation so make sure your key names do not collide with other users. Name your key something like `<some short somewhat unique id>-${OS_PROJECT_NAME}-api-key`. Then you add your public key the TACC dashboard with `nova keypair-add`.
    
    ```sh
    ssh-keygen -b 2048 -t rsa -f <key-name> -P ""
    nova keypair-add --pub-key id_rsa.pub <key-name>
    ```
    
    Your `.ssh` directory was mounted from outside the Docker container you are currently running. Your public/private key should be saved there. Don't lose it or else you may not be able to delete the VMs you are about to create.

3.  Testing Your Setup

    At this point, you should be able to run `glance image-list` which should yield something like:
    
    | ID                                   | Name                               |
    |------------------------------------ |---------------------------------- |
    | fd4bf587-39e6-4640-b459-96471c9edb5c | AutoDock Vina Launch at Boot       |
    | 02217ab0-3ee0-444e-b16e-8fbdae4ed33f | AutoDock Vina with ChemBridge Data |
    | b40b2ef5-23e9-4305-8372-35e891e55fc5 | BioLinux 8                         |
    
    If not, check your setup.


<a id="h:03303143"></a>

## Working with Jetstream API to Create VMs


<a id="h:5E7A7E65"></a>

### IP Numbers

We are ready to fire up VMs. First create an IP number which we will be using shortly:

```sh
nova floating-ip-create public
nova floating-ip-list
```

or you can just `nova floating-ip-list` if you have IP numbers left around from previous VMs.


<a id="h:EA17C2D9"></a>

### Boot VM

Now you can boot up a VM with something like the following command:

```sh
boot.sh -n unicloud -k <key-name> -s m1.medium -ip 149.165.157.137
```

The `boot.sh` command takes a VM name, [ssh key name](#h:EE48476C), size, and IP number created earlier, and optionally a network name or UUID. See `boot.sh -h` and `nova flavor-list` for more information.


<a id="h:9BEEAB97"></a>

### Create and Attach Data Volumes

You can create data volumes via the open stack `cinder` interface. As an example, here, we will be creating a 750GB `data` volume. You will subsequently attach the data volume to your VM with `nova` commands:

```sh
cinder create 750 --display-name data

cinder list && nova list

nova volume-attach <vm-uid-number> <volume-uid-number> auto
```

You will then be able to log in to your VM and mount your data volume with typical Unix `mount`, `umount`, and `df` commands.

There is a `mount.sh` convenience script to mount **uninitialized** data volumes.


<a id="h:D961F6F8"></a>

### ssh Into New VM

`ssh` into that newly minted VM:

```:eval
ssh ubuntu@149.165.157.137
```

If you are having trouble logging in, you may try to delete the `~/.ssh/known_hosts` file. If you still have trouble, try `nova stop <vm-uid-number>` followed by `nova start <vm-uid-number>`.
