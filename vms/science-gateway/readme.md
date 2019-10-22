- [Creating a Science Gateway VM on Jetstream](#h-49CACBE8)
  - [Create a Science Gateway VM on Jetstream](#h-593C3161)
  - [Clone the xsede-jetstream Repository](#h-1EA54D54)
  - [Prepare Science Gateway VM for Docker and docker-compose](#h-D311EB0F)
  - [Logging](#h-7FF2F781)
  - [Ports 80, 443](#h-5BF405FC)
  - [DNS Name](#h-F47D384F)
  - [Obtain HTTPS Certificates](#h-CE6457C8)
  - [Start Ngnix](#h-B30CBDF8)



<a id="h-49CACBE8"></a>

# Creating a Science Gateway VM on Jetstream


<a id="h-593C3161"></a>

## Create a Science Gateway VM on Jetstream

Create an `m1.small` VM with the [Jetstream OpenStack API](../../openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `science-gateway.unidata.ucar.edu`.


<a id="h-1EA54D54"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```


<a id="h-D311EB0F"></a>

## Prepare Science Gateway VM for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD archiver is relatively simple. [See here to install Docker and docker-compose](../../vm-init-readme.md).


<a id="h-7FF2F781"></a>

## Logging

The nginx log directory:

```shell
mkdir -p ~/logs/nginx/
```


<a id="h-5BF405FC"></a>

## Ports 80, 443

[Open ports](../../openstack/readme.md) `80`, and `443` on the Science Gateway VM via OpenStack.


<a id="h-F47D384F"></a>

## DNS Name

Work with Unidata sys admin staff to have the IP address of this VM point to science-gateway.unidata.ucar.edu.


<a id="h-CE6457C8"></a>

## Obtain HTTPS Certificates

Obtain HTTPS certificates from a certificate authority such as InCommon and put them in ~/ssl, e.g., `science-gateway.unidata.ucar.edu.crt` and `science-gateway.unidata.ucar.edu.key`.


<a id="h-B30CBDF8"></a>

## Start Ngnix

Once you have done the work of setting up nginx related directories,

```shell
docker-compose up -d
```

to start the web server.
