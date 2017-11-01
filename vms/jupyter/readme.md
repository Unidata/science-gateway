- [Creating a Jupyter VM on Jetstream](#h:CF2006B5)
  - [Create a Jupyter VM on Jetstream](#h:CD4EE10C)
  - [Clone the xsede-jetstream Repository](#h:30553515)
  - [Prepare Jupyter VM for Docker and docker-compose](#h:00BDD041)
  - [JupyterHub Configuration](#h:1217328A)
    - [jupyterhub\_config.py](#h:25E29186)
    - [nginx](#h:90A0BF68)
  - [Log Directories](#h:098522DC)
    - [JupyterHub](#h:A1CDED76)
    - [nginx](#h:69CC6370)
  - [SSL Certificate](#h:7D97FA52)
  - [Ports 80, 443, and 8000](#h:ED417641)
  - [Globus OAuth Setup](#h:524FAF4B)
  - [docker-compose.yml](#h:8F37201D)
  - [Start JupyterHub](#h:62B48A14)
  - [Navigate to JupyterHub](#h:4DCCED79)



<a id="h:CF2006B5"></a>

# Creating a Jupyter VM on Jetstream


<a id="h:CD4EE10C"></a>

## Create a Jupyter VM on Jetstream

Create an `m1.xlarge` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). [Create and attach](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97) a 1TB `/notebooks` and `/scratch` volumes to that VM. Work with Unidata system administrator staff to have this VM's IP address resolve to `jupyter-jetstream.unidata.ucar.edu`.


<a id="h:30553515"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```


<a id="h:00BDD041"></a>

## Prepare Jupyter VM for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing a JupyterHub server is relatively simple. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:1217328A"></a>

## JupyterHub Configuration


<a id="h:25E29186"></a>

### jupyterhub\_config.py

Copy the `jupyterhub_config.py` file to the `~/config/` directory. [Subsequently](#h:524FAF4B), you will have to make minor edits to supply the user and admin whitelist.

```shell
mkdir -p ~/config/
cp jupyterhub_config.py ~/config/
```


<a id="h:90A0BF68"></a>

### nginx

Must run nginx in parallel to JupyterHub to redirect `http` to `https`.

```shell
mkdir -p ~/nginx/
cp nginx.conf ~/nginx/
```


<a id="h:098522DC"></a>

## Log Directories


<a id="h:A1CDED76"></a>

### JupyterHub

The JupyterHub log directory:

```shell
mkdir -p ~/logs/jupyter/
```


<a id="h:69CC6370"></a>

### nginx

The nginx log directory:

```shell
mkdir -p ~/logs/nginx/
```


<a id="h:7D97FA52"></a>

## SSL Certificate

In the `~/config/ssl/` directory, obtain a `ssl.key`, `ssl.crt` certificate pair from a certificate authority (e.g., letsencrypt).

```shell
mkdir -p ~/config/ssl/
```

Or generate a self-signed certificate with `openssl`, but this is not recommended:

```shell
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/config/ssl/ssl.key \
  -out ~/config/ssl/ssl.crt
```


<a id="h:ED417641"></a>

## Ports 80, 443, and 8000

[Open ports](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) `80`, `443`, and `8000` on the Jupyter VM via OpenStack.


<a id="h:524FAF4B"></a>

## Globus OAuth Setup

This JupyterHub server makes use of [Globus OAuth capability](https://developers.globus.org/) for user authentication. The instructions [here](https://github.com/jupyterhub/oauthenticator#globus-setup) are relatively straightforward and mostly implemented in the [jupyterhub\_config.py](https://github.com/Unidata/xsede-jetstream/blob/master/vms/jupyter/jupyterhub_config.py) JupyterHub configuration file. The only tricky part is to supply the `OAUTH_CLIENT_ID` and `OAUTH_CLIENT_SECRET` environment variables which you obtain when registering the JupyterHub server application (e.g., `https://jupyter-jetstream.unidata.ucar.edu`) with Globus. Also in `jupyterhub_config.py`, supply the white list of administrator and users with `c.Authenticator.admin_users`, `c.Authenticator.whitelist` variables. For example,

```python
c.Authenticator.admin_users = {'jane','joe'}
c.Authenticator.whitelist = {'jen','james'}
```


<a id="h:8F37201D"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look something like:

```yaml
###
# JupyterHub + nginx
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
      - ~/ssl/:/etc/jupyterhub/ssl/
      - /notebooks:/notebooks
      - /scratch:/scratch
    ports:
      - "8000:8000"
      - "443:443"
    env_file:
      - "compose.env"
  web:
    image: nginx
    volumes:
      - ~/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ~/logs/nginx:/var/log/nginx
    ports:
      - "80:80"
```


<a id="h:62B48A14"></a>

## Start JupyterHub

Once you have done the work of setting up JupyterHub related directories,

```shell
docker-compose up -d
```

to start JupyterHub


<a id="h:4DCCED79"></a>

## Navigate to JupyterHub

In a web browser, navigate to [https://jupyter-jetstream.unidata.ucar.edu](https://jupyter-jetstream.unidata.ucar.edu).
