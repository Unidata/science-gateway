- [Creating a Science Gateway VM on Jetstream](#h:49CACBE8)
  - [Create a Science Gateway VM on Jetstream](#h:593C3161)
  - [Clone the xsede-jetstream Repository](#h:1EA54D54)
  - [Prepare Science Gateway VM for Docker and docker-compose](#h:D311EB0F)
  - [Logging](#h:7FF2F781)
  - [SSL Certificate](#h:35A542AF)
    - [Letsencrypt](#h:97AC4D3C)
  - [Ports 80, 443](#h:5BF405FC)
  - [Start Ngnix](#h:B30CBDF8)



<a id="h:49CACBE8"></a>

# Creating a Science Gateway VM on Jetstream


<a id="h:593C3161"></a>

## Create a Science Gateway VM on Jetstream

Create an `m1.small` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `science-gateway.unidata.ucar.edu`.


<a id="h:1EA54D54"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```


<a id="h:D311EB0F"></a>

## Prepare Science Gateway VM for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD archiver is relatively simple. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:7FF2F781"></a>

## Logging

The nginx log directory:

```shell
mkdir -p ~/logs/nginx/
```


<a id="h:35A542AF"></a>

## SSL Certificate

In the `~/config/ssl/` directory, obtain a `ssl.key`, `ssl.crt` certificate pair from a certificate authority (e.g., letsencrypt).

```shell
mkdir -p ~/config/ssl/
```


<a id="h:97AC4D3C"></a>

### Letsencrypt

First, ensure ports `80` and `443` [are open](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) on the VM in question. Generating a letsencrypt certificate with the `linuxserver/letsencrypt` Docker container is quite easy with this command:

```shell
docker run --name=letsencrypt -e PGID=1000 -e PUID=1000 \
       -e EMAIL=<email> -e URL=<URL of host> \
       -e VALIDATION=http  -p 80:80 -p 443:443  linuxserver/letsencrypt
```

Running this container will generate output indicating where to fetch the certificates. You can then copy the certificates out of the container with

```shell
docker cp <contain id>:<path to certs> ~/config/ssl/
```


<a id="h:5BF405FC"></a>

## Ports 80, 443

[Open ports](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) `80`, and `443` on the Science Gateway VM via OpenStack.


<a id="h:B30CBDF8"></a>

## Start Ngnix

Once you have done the work of setting up nginx related directories,

```shell
docker-compose up -d
```

to start the web server.
