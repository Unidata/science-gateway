- [Docker Installation](#h:BA11A408)
  - [Linux VM or Bare Metal Linux](#h:FF95E7EC)
    - [Quick Start](#h:4A4B1084)
    - [System Maintenance](#h:AE788331)
    - [Install Docker](#h:786799C4)
    - [Install docker-compose](#h:02EF6BAD)
    - [Start Docker Daemon](#h:B6F088A3)
    - [Reboot](#h:6D94F8D5)
    - [Docker Hello World](#h:F3633FE6)
  - [Other Environments (e.g., macOS, Windows)](#h:D1009153)



<a id="h:BA11A408"></a>

# Docker Installation

The `xsede-jetstream` project is heavily dependent on Docker, and you will have to have access to a recent version of Docker. Herein are some instructions to help you get going with Docker.


<a id="h:FF95E7EC"></a>

## Linux VM or Bare Metal Linux


<a id="h:4A4B1084"></a>

### Quick Start

Quick start instructions for Linux OS can be found here. For a more complete explanation of the Docker installation start with the [System Maintenance](#h:AE788331) section.

```shell
git clone https://github.com/Unidata/xsede-jetstream
```

and run the `docker-install.sh` script collocated with this readme, e.g.,:

```shell
cd xsede-jetstream
chmod +x docker-install.sh; sudo ./docker-install.sh -u ${USER}
```


<a id="h:AE788331"></a>

### System Maintenance

Always think before typing the following commands as `root` user!

Do the usual maintenance via `apt-get` or `yum`. Also install `git` for good measure.

1.  apt-get

    ```shell
    apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade \
        && apt-get -y install git
    ```

2.  yum

    ```shell
    yum -y update && yum -y install git
    ```


<a id="h:786799C4"></a>

### Install Docker

Define a `DOCKER_USER`. Again, think before you type.

```shell
curl -sSL get.docker.com | sh
usermod -aG docker ${DOCKER_USER}
```


<a id="h:02EF6BAD"></a>

### Install docker-compose

```shell
curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```


<a id="h:B6F088A3"></a>

### Start Docker Daemon

As `root` user, make sure Docker is available as a daemon. You can issue one of the following commands depending on your flavor of Linux.

```shell
service docker start
```

or

```shell
systemctl enable docker.service
systemctl start docker.service
```


<a id="h:6D94F8D5"></a>

### Reboot

Now reboot the machine:

```shell
reboot now
```

Log back into Linux machine or VM.


<a id="h:F3633FE6"></a>

### Docker Hello World

Run this container to make sure the docker install has gone smoothly:

```shell
docker run hello-world
```


<a id="h:D1009153"></a>

## Other Environments (e.g., macOS, Windows)

For other environments, see [the official docker installation documentation](https://docs.docker.com/engine/installation/).
