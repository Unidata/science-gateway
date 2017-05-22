- [Creating a RAMADDA VM on Jetstream](#h:07FD791D)
  - [Create a RAMADDA VM on Jetstream](#h:F4023EC5)
  - [Clone the xsede-jetstream Repository](#h:968FA51C)
  - [Start RAMADDA With Docker and docker-compose](#h:2E18E909)
  - [/repository Directory](#h:2F1A5636)
  - [RAMADDA log Directories](#h:1C3FF741)
  - [LDM Data Directory from idd-archiver Via NFS](#h:85431E50)
  - [Ensure /repository and /data Availability Upon Machine Restart](#h:6423976C)
    - [/data NFS Mounted Volume](#h:286B798E)
  - [Port 80](#h:404D9595)
  - [docker-compose.yml](#h:7E683535)
  - [Start RAMADDA](#h:224A9684)



<a id="h:07FD791D"></a>

# Creating a RAMADDA VM on Jetstream


<a id="h:F4023EC5"></a>

## Create a RAMADDA VM on Jetstream

Create an `m1.medium` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). [Create and attach](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97) a 100GB `/repository` volume to that VM. Work with Unidata system administrator staff to have this VM's IP address resolve to `ramadda-jetstream.unidata.ucar.edu`.


<a id="h:968FA51C"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h:2E18E909"></a>

## Start RAMADDA With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM with the RAMADDA content management system should be fairly easy. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:2F1A5636"></a>

## /repository Directory

The `/repository` directory should be a fairly beefy data volume (e.g., 100 GBs) or however much data you anticipate your RAMADDA users will consume. [See here if creating data volumes via the Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#create-and-attach-data-volumes).


<a id="h:1C3FF741"></a>

## RAMADDA log Directories

You will need an Apache Tomcat and RAMADDA log directories:

```shell
mkdir -p ~/logs/ramadda-tomcat/
mkdir -p ~/logs/ramadda/
```


<a id="h:85431E50"></a>

## LDM Data Directory from idd-archiver Via NFS

If you plan on employing the [server-side view capability of RAMADDA](http://ramadda.org//repository/userguide/developer/filesystem.html) which is quite useful for monitoring your LDM data feeds, you will have to make that directory (e.g., `/data/ldm/`) available to the RAMADDA VM and Docker container. In our present configuration, that directory is on the `idd-archiver` machine so you need to mount it via NFS on the `10.0.` network. For example, if `idd-archiver` is at `10.0.0.15`:

```sh
# create the NFS mount point
sudo mkdir -p /data
sudo mount 10.0.0.15:/data /data
```


<a id="h:6423976C"></a>

## Ensure /repository and /data Availability Upon Machine Restart

[Ensure the `/repository` volume availability upon machine restart](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97).


<a id="h:286B798E"></a>

### /data NFS Mounted Volume

In addition, you will want to ensure the NFS `/data` volume is also available with the help of `fstab`.

    10.0.0.15:/data    /data   nfs rsize=8192,wsize=8192,timeo=14,intr


<a id="h:404D9595"></a>

## Port 80

Open port `80` on your VM, however you do that so that RAMADDA can serve content via the web port. Port `80` requests will be forwarded to `8080` inside the RAMADDA Docker container. [See here](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) for more information on opening ports.


<a id="h:7E683535"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look something like:

```yaml
ramadda:
  image: unidata/ramadda-docker:2.2
  container_name: ramadda
  # restart: always
  ports:
    - "80:8080"
  volumes:
    - /repository/:/data/repository/
    - /data/ldm/:/data/ldm/
    - ~/logs/ramadda-tomcat/:/usr/local/tomcat/logs/
    - ~/logs/ramadda/:/data/repository/logs/
```


<a id="h:224A9684"></a>

## Start RAMADDA

Once you have done the work of setting up RAMADDA related directories in the way you like,

```shell
docker-compose up -d
```

to start RAMADDA.
