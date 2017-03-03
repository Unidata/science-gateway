- [Docker Installation](#orgheadline11)
  - [Linux VM or Bare Metal Linux](#orgheadline9)
    - [System Maintenance](#orgheadline3)
    - [Install Docker](#orgheadline4)
    - [Install docker-compose](#orgheadline5)
    - [Start Docker Daemon](#orgheadline6)
    - [Reboot](#orgheadline7)
    - [Docker Hello World](#orgheadline8)
  - [Other Environments (e.g., macOS, Windows)](#orgheadline10)


# Docker Installation<a id="orgheadline11"></a>

The `xsede-jetstream` project is heavily dependent on Docker. Herein are some instructions to help you get going with Docker.

## Linux VM or Bare Metal Linux<a id="orgheadline9"></a>

Always think before typing the following commands as `root` user!

### System Maintenance<a id="orgheadline3"></a>

Do the usual maintenance via `apt-get` or `yum`. Also install `git` for good measure.

1.  apt-get

    ```sh
    apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade && \
        apt-get -y install git
    ```

2.  yum

    ```sh
    yum -y update && yum -y install git
    ```

### Install Docker<a id="orgheadline4"></a>

Again, think before you type.

```sh
curl -sSL get.docker.com | sh
usermod -aG docker <username>
```

### Install docker-compose<a id="orgheadline5"></a>

```sh
curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```

### Start Docker Daemon<a id="orgheadline6"></a>

As `root` user, make sure Docker is available as a daemon. You can issue one of the following commands depending on your flavor of Linux.

```sh
service start docker
```

or

```sh
systemctl enable docker.service
systemctl start docker.service
```

### Reboot<a id="orgheadline7"></a>

Now reboot the machine:

```sh
reboot now
```

Log back into Linux machine or VM.

### Docker Hello World<a id="orgheadline8"></a>

Run this container to make sure the docker install has gone smoothly:

```sh
docker run hello-world
```

## Other Environments (e.g., macOS, Windows)<a id="orgheadline10"></a>

For other environments, see [the official docker installation documentation](https://docs.docker.com/engine/installation/).
