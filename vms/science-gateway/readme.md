- [Creating a Science Gateway VM on Jetstream](#h-49CACBE8)
  - [Create a Science Gateway VM on Jetstream](#h-593C3161)
  - [Clone the science-gateway Repository](#h-1EA54D54)
  - [Build the Science Gateway Docker Container](#h-4A66EE99)
  - [Prepare Science Gateway VM for Docker and docker-compose](#h-D311EB0F)
  - [Logging](#h-7FF2F781)
  - [Ports 80, 443](#h-5BF405FC)
  - [DNS Name](#h-F47D384F)
  - [Obtain HTTPS Certificates](#h-CE6457C8)
    - [OCSP stapling](#h-A7B71EC8)
  - [Start Science Gateway](#h-B30CBDF8)



<a id="h-49CACBE8"></a>

# Creating a Science Gateway VM on Jetstream


<a id="h-593C3161"></a>

## Create a Science Gateway VM on Jetstream

Create an `m1.small` VM with the [Jetstream OpenStack API](../../openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `science-gateway.unidata.ucar.edu`.


<a id="h-1EA54D54"></a>

## Clone the science-gateway Repository

We will be making heavy use of the `Unidata/science-gateway` git repository.

```shell
git clone https://github.com/Unidata/science-gateway ~/science-gateway
```


<a id="h-4A66EE99"></a>

## Build the Science Gateway Docker Container

From the `~/science-gateway/vms/science-gateway` directory:

```shell
docker build -t unidata/science-gateway:latest .
```


<a id="h-D311EB0F"></a>

## Prepare Science Gateway VM for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD archiver is relatively simple. [See here to install Docker and docker-compose](../../vm-init-readme.md).


<a id="h-7FF2F781"></a>

## Logging

Create the following nginx log directory:

```shell
mkdir -p /logs/nginx
```


<a id="h-5BF405FC"></a>

## Ports 80, 443

[Open ports](../../openstack/readme.md) `80`, and `443` on the Science Gateway VM via OpenStack.


<a id="h-F47D384F"></a>

## DNS Name

Work with Unidata sys admin staff to have the IP address of this VM point to science-gateway.unidata.ucar.edu.


<a id="h-CE6457C8"></a>

## Obtain HTTPS Certificates

Work with system admin staff to obtain an HTTPS key and certificate from a certificate authority such as InCommon. Put them in `/etc/ssl/science-gateway/`, e.g., `science-gateway.unidata.ucar.edu.key` and `science-gateway.unidata.ucar.edu.crt`. Ensure these are owned by root and set to read only. The certificate must include intermediate certificates for security purposes. You can test the security quality of the website with [ssllabs test](https://www.ssllabs.com/ssltest/).


<a id="h-A7B71EC8"></a>

### OCSP stapling

[OCSP (Online Certificate Status Protocol) stapling](https://en.wikipedia.org/wiki/OCSP_stapling) is recommended for web server communication privacy and efficiency. To enable this feature in an nginx server, have a file containing the intermediate and root certificates. Simply take the full chain certificate file described above and remove the base certificate leaving the intermediate and root certificates only. Call this file `ca-certs.pem` and put it in the `/etc/ssl/` directory along side the `key` and `crt` file described above. It will be mounted into the container with [docker-compose.yml](../../../vms/science-gateway/docker-compose.yml) and referred to in `nginx.conf` with

```fundamental
ssl_trusted_certificate /etc/nginx/ca-certs.pem
```


<a id="h-B30CBDF8"></a>

## Start Science Gateway

Once you have done the work of setting up nginx related directories,

```shell
docker-compose up -d
```

to start the web server.
