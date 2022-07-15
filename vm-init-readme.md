- [Virtual Machine Initialization](#h-BA11A408)
  - [Linux VM or Bare Metal Linux](#h-FF95E7EC)
    - [Quick Start](#h-4A4B1084)
    - [System Maintenance](#h-AE788331)
    - [Install Docker (Ubuntu)](#h-786799C4)
    - [Install Docker (Rocky)](#rocky-docker)
    - [Install docker-compose](#h-02EF6BAD)
    - [Create the docker Group](#docker-group)
    - [Start Docker Daemon](#h-B6F088A3)
    - [Logging](#h-E37376D1)
    - [Reboot](#h-6D94F8D5)
    - [Docker Hello World](#h-F3633FE6)
  - [Other Environments (e.g., macOS, Windows)](#h-D1009153)



<a id="h-BA11A408"></a>

# Virtual Machine Initialization

The `science-gateway` project is heavily dependent on Docker, and you will have
to have access to a recent version of Docker. Herein are some instructions to
help you get going with Docker and other system maintenance you will need to
perform. The commands laid out by these instructions are contained in the
convenience scripts `rocky-init.sh` and `ubuntu-init.sh`. However, only
`rocky-init.sh` is being actively maintained as RockyLinux has become the OS of
choice for JetStream2 VMs.


<a id="h-FF95E7EC"></a>

## Linux VM or Bare Metal Linux

<a id="h-4A4B1084"></a>

### Quick Start

Quick start instructions for Linux OS can be found here. For a more complete
explanation of the Docker installation start with the [System
Maintenance](#h-AE788331) section. Clone the science-gateway repository:

```shell
git clone https://github.com/Unidata/science-gateway
```

and run the `ubuntu-init.sh` or `rocky-init.sh` as root, script co-located with
this readme. Many of the commands found below (and within those scripts) require
root privileges. As always, ensure you know what you're doing before running
anything as root:

```shell
cd science-gateway
sudo ./<linux-distro>-init.sh
```

Optionally, include the `-d or --docker` flag with the appropriate argument (see
[Install Docker (Rocky)](#rocky-docker)) if `docker` will be ran on the VM, and
the `-n or --nfs` flag if the VM will act as a NFS server.

<a id="h-AE788331"></a>

### System Maintenance

Always think before typing the following commands as `root` user!

Do the usual maintenance via `apt-get` or `yum`. Also install a few ancillary
packages and repositories (e.g., `git`, etc.) for good measure. Purge Docker and
any other packages from the system that may conflict with a fresh Docker
installation.

1.  apt-get

    ```shell
    service docker stop

    # See https://askubuntu.com/questions/990268/usr-sbin-fanctl-no-such-file-or-directory-in-etc-network-if-up-d-ubuntu-fan
    # about why we remove ubuntu-fan, for now.

    dpkg --configure -a && apt-get remove -y docker docker-engine docker.io \
       docker-ce && apt remove -y --purge ubuntu-fan && rm -rf /var/lib/docker \
        && apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade \
        && apt-get -y install git unzip wget nfs-kernel-server nfs-common \
        && apt autoremove -y
    ```

2.  yum

    ```shell
    systemctl stop docker

	# Remove any existing packages that may conflict with the installation
	yum -y remove docker docker-common docker-selinux docker-engine-selinux \
	  docker-engine docker-ce podman buildah && rm -rf /var/lib/docker

	# Upgrade existing packages and install the Extra Packages for Enterprise Linux repo
	yum -y upgrade && yum install -y epel-release

	# Desired packages for basic use
	yum install -y sudo man man-pages vim nano git wget unzip ncurses procps htop \
		python3 telnet openssh openssh-clients openssl findutils \
		tmux
    ```


<a id="h-786799C4"></a>

### Install Docker (Ubuntu)

On Ubuntu, you can install docker using a convencience script provided by the
docker folks:


```shell
# To inspect the script before running anything, pipe the output of the curl
# command into your favorite text viewer, such as less or vim
curl -sSL get.docker.com | less

# Run the script
curl -sSL get.docker.com | sh
```

<a id="rocky-docker"></a>

### Install Docker (Rocky)

The convenience script used to install docker on Ubuntu does not have RockyLinux
support, however, we can still manually install everything from the centOS
repository.

```shell
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
```

<a id="h-02EF6BAD"></a>

### Install docker-compose

Docker compose is a tool for running multi-container docker applications through
a `docker-compose.yml` configuration file, but is also useful for defining how
single container applications should be ran by specifiying parameters such as
volume mounts and environment variables.

The most recent version of docker compose, acts as a plugin to docker:

```shell
# Install docker-compose (v2 acts as a plugin to the docker CLI)
DOCKER_CONFIG=${DOCKER_CONFIG:-/home/$DOCKER_USER/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

# Make $USER the owner of the created directory, and make the plugin executable
chown -R $DOCKER_USER:$DOCKER_USER $DOCKER_CONFIG
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

<a id="docker-group"></a>

### Create the docker Group

Create a `docker` group and add the supplied `DOCKER_USER` to this group. This
allows `$DOCKER_USER` to run docker commands without root privileges. Again,
think before you type.

```shell
group add docker
usermod -aG docker ${DOCKER_USER}
```

<a id="h-B6F088A3"></a>

### Start Docker Daemon

As `root` user, make sure Docker is available as a daemon. You can issue one of the following commands depending on your flavor of Linux.

```shell
# Ubuntu
service docker start
```

or

```shell
# Rocky
systemctl enable docker.service
systemctl start docker.service
```

<a id="h-E37376D1"></a>

### Logging

Set up standard logging directory:

```shell
mkdir /logs
chown -R ${DOCKER_USER}:docker /logs
```


<a id="h-6D94F8D5"></a>

### Reboot

Now reboot the machine:

```shell
reboot now
```

Log back into Linux machine or VM.


<a id="h-F3633FE6"></a>

### Docker Hello World

Run this container to make sure the docker install has gone smoothly:

```shell
docker run hello-world
docker compose --help
docker-compose --help
```

<a id="h-D1009153"></a>

## Other Environments (e.g., macOS, Windows)

For other environments, see [the official docker installation documentation](https://docs.docker.com/engine/installation/).
