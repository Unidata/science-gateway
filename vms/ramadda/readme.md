- [Creating a RAMADDA VM on Jetstream](#h:07FD791D)
  - [Clone the xsede-jetstream Repository](#h:968FA51C)
  - [Start RAMADDA With Docker and docker-compose](#h:2E18E909)
  - [/repository Directory](#h:2F1A5636)
  - [RAMADDA log Directories](#h:1C3FF741)
  - [LDM Data Directory (Optional)](#h:85431E50)
  - [Port 80](#h:404D9595)
  - [docker-compose.yml](#h:7E683535)
  - [Start RAMADDA](#h:224A9684)



<a id="h:07FD791D"></a>

# Creating a RAMADDA VM on Jetstream


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

## LDM Data Directory (Optional)

I you plan on using the [server-side view capability of RAMADDA](http://ramadda.org//repository/userguide/developer/filesystem.html) which is quite useful for monitoring your LDM data feeds, you will have to make that directory (e.g., `/data/ldm/`) available to RAMADDA container.


<a id="h:404D9595"></a>

## Port 80

Open port `80` on your VM, however you do that so that RAMADDA can serve content via the web port. Port `80` requests will be forwarded to `8080` inside the RAMADDA Docker container. [See here](https://github.com/Unidata/xsede-jetstream/tree/secgroups/openstack#h:D6B1D4C2) for more information on opening ports.


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
