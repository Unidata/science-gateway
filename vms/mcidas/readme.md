- [Creating an ADDE VM on Jetstream](#h:E8DA29EC)
  - [Create an ADDE VM on Jetstream](#h:10109CCE)
  - [Clone the xsede-jetstream Repository](#h:E6D3D21F)
  - [Start ADDE With Docker and docker-compose](#h:0897ADA4)
  - [ADDE Configuration](#h:C9A644E9)
  - [LDM Data Directory from idd-archiver Via NFS](#h:D58FB64C)
    - [Ensure /data Availability Upon Machine Restart](#h:C586CD26)
  - [Port 112](#h:3E2295A4)
  - [docker-compose.yml](#h:E8896F4D)
  - [Start ADDE](#h:CD5F66AF)
  - [Access ADDE from the IDV](#h:F5719715)



<a id="h:E8DA29EC"></a>

# Creating an ADDE VM on Jetstream


<a id="h:10109CCE"></a>

## Create an ADDE VM on Jetstream

Create an `m1.medium` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `adde-jetstream.unidata.ucar.edu`.


<a id="h:E6D3D21F"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h:0897ADA4"></a>

## Start ADDE With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM with an ADDE server should be fairly easy. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:C9A644E9"></a>

## ADDE Configuration

A minor amount of configuration is required to get ADDE going.

```shell
mkdir -p ~/etc ~/mcidas/upcworkdata/ ~/mcidas/decoders/ ~/mcidas/util/
cp pqact.conf_mcidasA ~/etc
cp RESOLV.SRV ~/mcidas/upcworkdata/
```


<a id="h:D58FB64C"></a>

## LDM Data Directory from idd-archiver Via NFS

ADDE will need access to the `/data/ldm/` directory from `idd-archiver` in order to serve data. Mount it via NFS on the `10.0.` network. For example, if `idd-archiver` is at `10.0.0.4`:


```shell
# create the NFS mount point
mkdir -p /data
mount 10.0.0.4:/data /data
```


<a id="h:C586CD26"></a>

### Ensure /data Availability Upon Machine Restart

You will want to ensure the NFS `/data` volume is available with the help of `fstab`.

```shell
echo 10.0.0.4:/data    /data   nfs rsize=32768,wsize=32768,timeo=14,intr | tee --append /etc/fstab > /dev/null
```


<a id="h:3E2295A4"></a>

## Port 112

ADDE operates via port `112`. [Open port](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) `112` on the ADDE VM via OpenStack.


<a id="h:E8896F4D"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file that looks like:

```yaml
###
# McIDAS
###

version: '3'

services:
  mcidas:
    image: unidata/mcidas
    container_name: mcidas
    # restart: always
    volumes:
      # Directories outside of the container that need to be accessible
      - ~/mcidas/upcworkdata/:/home/mcidas/upcworkdata/
      - ~/mcidas/util/:/home/mcidas/util/
      - ~/mcidas/decoders/:/home/mcidas/decoders/
      - /data/ldm/pub:/data/ldm/pub/
    ports:
      - "112:112"
```

Note the `unidata/mcidas` container is closed source so is unavailable at DockerHub. Contact Unidata for more information.


<a id="h:CD5F66AF"></a>

## Start ADDE

Once you have done the work of setting up ADDE related directories in the way you like,

```shell
docker-compose up -d
```

to start ADDE.


<a id="h:F5719715"></a>

## Access ADDE from the IDV

To verify all is in order, access this ADDE server from the Unidata IDV by pointing to the `adde-jetstream.unidata.ucar.edu` server in the Image Data Chooser.
