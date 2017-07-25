- [Creating a Jupyter VM on Jetstream](#h:CF2006B5)
  - [Create a Jupyter VM on Jetstream](#h:CD4EE10C)
  - [Clone the xsede-jetstream](#h:30553515)
  - [Prepare Jupyter VM for Docker and docker-compose](#h:00BDD041)
  - [Jupyter Configuration](#h:1217328A)
  - [Jupyter log Directory](#h:098522DC)
  - [SSL Certificate](#h:7D97FA52)
  - [Ports 80, 443, and 8000](#h:ED417641)
  - [docker-compose.yml](#h:8F37201D)
  - [Start JupyterHub](#h:62B48A14)
  - [Passwords for Users](#h:742BC415)
  - [Navigate to JupyterHub](#h:4DCCED79)



<a id="h:CF2006B5"></a>

# Creating a Jupyter VM on Jetstream


<a id="h:CD4EE10C"></a>

## Create a Jupyter VM on Jetstream

Create an `m1.xlarge` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). [Create and attach](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97) a 1TB `/notebooks` and `/scratch` volumes to that VM. Work with Unidata system administrator staff to have this VM's IP address resolve to `jupyter-jetstream.unidata.ucar.edu`.


<a id="h:30553515"></a>

## Clone the xsede-jetstream

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```


<a id="h:00BDD041"></a>

## Prepare Jupyter VM for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD archiver is relatively simple. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:1217328A"></a>

## Jupyter Configuration

```shell
mkdir -p ~/config/
cp jupyterhub_config.py ~/config/
```

Edit the `~/config/jupyterhub_config.py`.


<a id="h:098522DC"></a>

## Jupyter log Directory

You will need Apache Tomcat and TDS log directories:

```shell
mkdir -p ~/logs/jupyter/
```


<a id="h:7D97FA52"></a>

## SSL Certificate

In the `~/xsede-jetstream/vms/jupyter/files/` directory, generate a self-signed certificate with `openssl` (or better yet, obtain a real certificate from a certificate authority).

```shell
mkdir -p ~/config/ssl/

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/config/ssl/ssl.key \
  -out ~/config/ssl/ssl.crt
```


<a id="h:ED417641"></a>

## Ports 80, 443, and 8000

[Open ports](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) `80`, `443`, and `8000` on the Jupyter VM via OpenStack.


<a id="h:8F37201D"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look something like:

```yaml
###
# JupyterHub
###

version: '3'

services:
  jupyter:
    image: unidata/unidatahub
    container_name: jupyter
    # restart: always
    volumes:
      # Directories outside of the container that need to be accessible
      - ~/config:/etc/jupyterhub
      - ~/logs/jupyter:/var/log
      - /notebooks:/notebooks
      - /scratch:/scratch
    ports:
      - "8000:8000"
      - "80:80"
      - "443:443"
    env_file:
      - "compose.env"
```


<a id="h:62B48A14"></a>

## Start JupyterHub

Once you have done the work of setting up JupyterHub related directories,

```shell
docker-compose up -d
```

to start JupyterHub


<a id="h:742BC415"></a>

## Passwords for Users

Assign temporary passwords for admin and whitelisted users defined earlier in the `~/config/jupyterhub_config.py`.

You can generate random passwords with `openssl`. For example,

```shell
openssl rand -base64 12
```

Followed by:

```shell
docker exec jupyter /bin/sh -c 'echo <user>:<password> | /usr/sbin/chpasswd'
```

Communicate that password to the user via email. Have them change their password by logging into this JupyterHub instance with the username and temporary password and going to New, Terminal which will open a Unix terminal. Have them run `passwd` command.


<a id="h:4DCCED79"></a>

## Navigate to JupyterHub

In a web browser, navigate to [<https://jupyter-jetstream.unidata.ucar.edu:8000>](https://jupyter-jetstream.unidata.ucar.edu:8000).
