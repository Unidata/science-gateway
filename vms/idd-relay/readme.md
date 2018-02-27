- [Creating an IDD Relay on Jetstream](#h:840E89CB)
  - [Create an IDD Relay VM on Jetstream](#h:4BF1C37C)
  - [Clone the xsede-jetstream Repository](#h:7544DE64)
  - [Start IDD Relay With Docker and docker-compose](#h:C89E3FF5)
  - [~/etc Directory](#h:E4AB4451)
  - [~/queues Directory](#h:F3D77CEF)
  - [~/logs Directory](#h:515DAD84)
  - [Port 388](#h:FB14DD93)
  - [docker-compose.yml](#h:95441A93)
    - [LDM Environment Variable Parameterization](#h:031CD94A)
  - [Start the IDD Relay Node](#h:80DA881B)



<a id="h:840E89CB"></a>

# Creating an IDD Relay on Jetstream


<a id="h:4BF1C37C"></a>

## Create an IDD Relay VM on Jetstream

Create an `m1.medium` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `idd-relay-jetstream.unidata.ucar.edu`.


<a id="h:7544DE64"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h:C89E3FF5"></a>

## Start IDD Relay With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD relay is simple. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:E4AB4451"></a>

## ~/etc Directory

This `~/etc` directory will contain your LDM configuration files.

```shell
mkdir -p ~/etc
cp ~/xsede-jetstream/vms/idd-relay/etc/* ~/etc/
```

You may have to tailor the `ldmd.conf` to your data feed requirements. Also edit the `registry.xml` file to update the `hostname` element so that Real-Time IDD Statistics can be properly reported. Finally, you may have to adjust the size of the queue currently at 10GBs.


<a id="h:F3D77CEF"></a>

## ~/queues Directory

This `~/queues` directory will contain the LDM queue file.

```shell
mkdir -p ~/queues
```


<a id="h:515DAD84"></a>

## ~/logs Directory

Create the LDM `logs` directory.

```shell
mkdir -p ~/logs/ldm
```


<a id="h:FB14DD93"></a>

## Port 388

Open LDM port `388` so that this VM may function as an IDD relay node. [See here](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:D6B1D4C2) for more information on opening ports.


<a id="h:95441A93"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look something like:

```yaml
###
# LDM
###
ldm:
  # restart: always
  image: unidata/ldm-docker:6.13.6
  container_name: ldm
  volumes:
    - ~/etc/:/home/ldm/etc/
    - ~/queues:/home/ldm/var/queues/
    - ~/logs/ldm/:/home/ldm/var/logs/
  ports:
    - "388:388"
  ulimits:
    nofile:
      soft: 1024
      hard: 1024
  env_file:
    - "compose.env"
```


<a id="h:031CD94A"></a>

### LDM Environment Variable Parameterization

You can provide additional LDM parameterization via the `compose.env` file referenced in the `docker-compose.yml` file.

```shell
# https://github.com/Unidata/ldm-docker#configurable-ldm-uid-and-gid

LDM_USER_ID=1000

LDM_GROUP_ID=1000
```


<a id="h:80DA881B"></a>

## Start the IDD Relay Node

To start the IDD relay node:

```shell
# wherever you cloned the repo above
cd ~/xsede-jetstream/vms/idd-relay/
docker-compose up -d
```
