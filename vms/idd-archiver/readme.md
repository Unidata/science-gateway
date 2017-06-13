- [Creating an IDD Archiver on Jetstream](#h:046F9FE1)
  - [Create an IDD Archiver VM on Jetstream](#h:304AA966)
  - [Clone the xsede-jetstream and TdsConfig Repositories](#h:00BE67D7)
  - [Prepare IDD Archiver for Docker and docker-compose](#h:FF66923F)
  - [~/etc Directory](#h:B5A9CA86)
    - [~/etc/ldmd.conf](#h:A598B286)
    - [~/etc/registry.xml](#h:27A09559)
  - [Data Scouring](#h:1CA59DB7)
  - [pqacts](#h:4BDFE35D)
  - [Edit ldmfile.sh](#h:D2BD1E3A)
  - [/data/ldm/queues Directory](#h:2428D469)
  - [/data/ldm/logs Directory](#h:57DC40FF)
  - [Ensure /data Volume Availability Upon Machine Restart](#h:3CE81256)
  - [Sharing /data directory via NFS](#h:358A22F4)
    - [Open NFS Related Ports](#h:1AFDC551)
  - [THREDDS Data Manager (TDM)](#h:DB469C8D)
    - [TDM Logging Directory](#h:865C1FF8)
    - [Configuring the TDM to work with the TDS](#h:2C5BF1CA)
  - [docker-compose.yml](#h:498535EC)
  - [Start the IDD Archiver Node](#h:4167D52C)



<a id="h:046F9FE1"></a>

# Creating an IDD Archiver on Jetstream


<a id="h:304AA966"></a>

## Create an IDD Archiver VM on Jetstream

Create an `m1.small` VM with the [Jetstream OpenStack API](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md). [Create and attach](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97) a 5TB `/data` volume to that VM. Work with Unidata system administrator staff to have this VM's IP address resolve to `idd-archiver-jetstream.unidata.ucar.edu`.


<a id="h:00BE67D7"></a>

## Clone the xsede-jetstream and TdsConfig Repositories

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```

In addition, we will employ the `Unidata/TdsConfig` repository to obtain our LDM pqacts. We will **not** be running the TDS on the IDD archiver VM.

```shell
git clone https://github.com/Unidata/TdsConfig ~/TdsConfig
```


<a id="h:FF66923F"></a>

## Prepare IDD Archiver for Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM containing an IDD archiver is relatively simple. [See here to install Docker and docker-compose](https://github.com/Unidata/xsede-jetstream/blob/master/docker-readme.md).


<a id="h:B5A9CA86"></a>

## ~/etc Directory

This `~/etc` directory will contain your LDM configuration files.

```shell
mkdir -p ~/etc
cp ~/xsede-jetstream/vms/idd-archiver/etc/* ~/etc/
```


<a id="h:A598B286"></a>

### ~/etc/ldmd.conf

You may have to tailor the `ldmd.conf` to your data feed requirements. In addition, change the following request line

```shell
REQUEST ANY ".*" 10.0.0.8
```

to point the local IDD relay **10.0 address**.


<a id="h:27A09559"></a>

### ~/etc/registry.xml

Verify the `registry.xml` file is updated the `hostname` element with `idd-archiver.jetstream-cloud.org` so that Real-Time IDD statistics can be properly reported back to Unidata. Finally, you may have to adjust the size of the queue currently at `6G`.


<a id="h:1CA59DB7"></a>

## Data Scouring

Scouring the `/data/ldm` directory is achieved through the LDM `scour.conf` mechanism and scouring utilities. See the [ldm-docker project README](https://github.com/Unidata/ldm-docker) for details. Examine the `etc/scour.conf`, `cron/ldm`, and `docker-compose.yml` to ensure scouring of data happens in the time frame you wish.


<a id="h:4BDFE35D"></a>

## pqacts

Unpack the pqacts configurations from the `TdsConfig` project and put them in the expected `~/etc/TDS` location.

```shell
mkdir -p ~/tdsconfig/ ~/etc/TDS
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/idd/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS
```


<a id="h:D2BD1E3A"></a>

## Edit ldmfile.sh

Examine the `~/etc/TDS/util/ldmfile.sh` file. As the top of this file indicates, you must change the `logfile` to suit your needs. Change the

    logfile=logs/ldm-mcidas.log

line to

    logfile=var/logs/ldm-mcidas.log

This will ensure `ldmfile.sh` can properly invoked from the `pqact` files.

We can achieve this change with a bit of `sed`:

```shell
# in place change of logs dir w/ sed
sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
    ~/etc/TDS/util/ldmfile.sh
```

Also ensure that `ldmfile.sh` is executable.

```shell
chmod +x ~/etc/TDS/util/ldmfile.sh
```


<a id="h:2428D469"></a>

## /data/ldm/queues Directory

This `queues` directory will contain the LDM queue file.

```shell
mkdir -p /data/ldm/queues
```


<a id="h:57DC40FF"></a>

## /data/ldm/logs Directory

Create the LDM `logs` directory.

```shell
mkdir -p /data/ldm/logs/
```


<a id="h:3CE81256"></a>

## Ensure /data Volume Availability Upon Machine Restart

[Ensure `/data` volume availability upon machine restart](https://github.com/Unidata/xsede-jetstream/blob/master/openstack/readme.md#h:9BEEAB97).


<a id="h:358A22F4"></a>

## Sharing /data directory via NFS

Because volume multi-attach is not yet available via OpenStack, we will want to share the `/data` directory via NFS to client VMs over the `10.0` network by adding and an entry to the `/etc/exports` file. For example, here we are sharing the `/data` directory to the VM at `10.0.0.18`.

```shell
echo /data		10.0.0.18(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
echo /data		10.0.0.19(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
```

Now start NFS:

```shell
exportfs -a
service nfs-kernel-server start
```

Finally, ensure NFS will be available when the VM starts:

```shell
update-rc.d nfs-kernel-server defaults
```


<a id="h:1AFDC551"></a>

### Open NFS Related Ports

Via OpenStack also open NFS related ports: `111`, `1110`, `2049`, `4045`. If it does not exist already, create the `global-nfs` security group with the `secgroup.sh` convenience script and additional `openstack` commands.

```shell
# Will create a "global-nfs" security group.
secgroup.sh  -p 111 -n nfs
openstack security group rule create global-nfs --protocol tcp --dst-port 1110:1110 --remote-ip 0.0.0.0/0
openstack security group rule create global-nfs --protocol tcp --dst-port 2049:2049 --remote-ip 0.0.0.0/0
openstack security group rule create global-nfs --protocol tcp --dst-port 4045:4045 --remote-ip 0.0.0.0/0
```

Finally, attach the `global-nfs` security group to the newly created VM. The VM ID can be obtained with `openstack server list`.

```shell
openstack server add security group <VM name or ID> global-nfs
```


<a id="h:DB469C8D"></a>

## THREDDS Data Manager (TDM)

While not related to IDD archival, the [TDM](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) is an application that works in conjunction with the TDS. It creates indexes for GRIB data as a background process, and notifies the TDS running on the `thredds-jetstream` VM via port `8443` when data have been updated or changed. Because the TDM needs to **write** data, and NFS tuning concerns, in the present configuration, we have the TDM running on the `idd-archiver-jetstream` VM.


<a id="h:865C1FF8"></a>

### TDM Logging Directory

Create a logging directory for the TDM:

```shell
mkdir -p ~/logs/tdm
```

1.  Running the TDM Out the TDM Log Directory

    [TDM logging will not be configurable until TDS 5.0](https://github.com/Unidata/tdm-docker#capturing-tdm-log-files-outside-the-container). Until then we are running the TDM out of the `~/logs/tdm` directory:
    
    ```shell
    curl -SL  \
         https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.10/tdmFat-4.6.10.jar \
         -o ~/logs/tdm/tdm.jar
    curl -SL https://raw.githubusercontent.com/Unidata/tdm-docker/master/tdm.sh \
         -o ~/logs/tdm/tdm.sh
    chmod +x  ~/logs/tdm/tdm.sh
    ```


<a id="h:2C5BF1CA"></a>

### Configuring the TDM to work with the TDS

In the `docker-compose.yml` shown below, there is a reference to a `compose.env` file that contains TDM related environment variables.

```shell
# TDS Content root

TDS_CONTENT_ROOT_PATH=/usr/local/tomcat/content

# TDM related environment variables

TDM_PW=CHANGEME!

# Trailing slash is important!
TDS_HOST=http://thredds-jetstream.unidata.ucar.edu/

# The minimum and maximum Java heap space memory to be allocated to the TDM

TDM_XMX_SIZE=6G

TDM_XMS_SIZE=1G
```

Let's consider each environment variable (i.e., configuration option), in turn.

1.  `TDS_CONTENT_ROOT_PATH`

    This environment variable relates to the TDS content root **inside** the container and probably does not need to be changed.

2.  `TDM_PW`

    Supply the TDM password. For example,
    
        TDM_PW=CHANGEME!
    
    Note that this password should correspond to the SHA digested password of the `tdm` user in `~/xsede-jetstream/vm/thredds/files/tomcat-users.xml` file on the **thredds-jetstream** VM. You can create a password/SHA pair with the following command:
    
    ```shell
    docker run tomcat  /usr/local/tomcat/bin/digest.sh -a "SHA" CHANGEME!
    ```

3.  `TDS_HOST`

    Supply the hostname of the TDS that the TDM will notify:
    
        TDS_HOST=http://thredds-jetstream.unidata.ucar.edu/

4.  `TDM_XMX_SIZE`, `TDM_XMS_SIZE`

    Define the maximum and minimum size of the Java heap under which the TDM can operate:
    
        TDM_XMX_SIZE=6G
        
        TDM_XMS_SIZE=1G


<a id="h:498535EC"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look like this:

```yaml
version: '3'

services:

  ###
  # LDM
  ###
  ldm:
    image: unidata/ldm-docker:6.13.6
    container_name: ldm
    # restart: always
    volumes:
      - ~/etc/:/home/ldm/etc/
      - /data/:/home/ldm/var/data/
      - /data/:/data/
      - /data/ldm/queues:/home/ldm/var/queues/
      - /data/ldm/logs/:/home/ldm/var/logs/
      - ./cron/:/var/spool/cron/
    ports:
      - "388:388"
    ulimits:
      nofile:
        soft: 64
        hard: 64
  
  ###
  # TDM
  ###
  tdm:
    image: unidata/tdm-docker:4.6
    container_name: tdm
    # restart: always
    volumes:
        - /data/:/data/
        - ~/tdsconfig/:/usr/local/tomcat/content/thredds/
        - ~/logs/tdm/:/usr/local/tomcat/content/tdm/
    env_file:
        - "compose${THREDDS_COMPOSE_ENV_LOCAL}.env"
```


<a id="h:4167D52C"></a>

## Start the IDD Archiver Node

To start the IDD archiver node:

```shell
cd ~/xsede-jetstream/vms/idd-archiver/
docker-compose up -d
```
