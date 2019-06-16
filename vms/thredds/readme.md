- [Create a THREDDS VM on Jetstream](#h:A57251FC)
  - [Create a THREDDS VM on Jetstream](#h:011CFB59)
  - [Clone the xsede-jetstream Repository](#h:E1E7DBE4)
  - [Start TDS With Docker and docker-compose](#h:704AF626)
  - [TDS Configuration](#h:1E5D6712)
    - [Supply Contact and Host Information in threddsConfig.xml](#h:3F46F49F)
  - [TDS log Directories](#h:E0771AED)
    - [Create log Directories](#h:F83FDEE6)
    - [Scour log Directories](#h:7BF272F0)
  - [LDM Data Directory from idd-archiver Via NFS](#h:F043AB6A)
    - [Ensure /data Availability Upon Machine Restart](#h:437D2B38)
  - [SSL Certificate](#h:C5008DD9)
  - [Ports 80, 443 and 8443](#h:68B4119B)
  - [THREDDS Data Manager (TDM)](#h:0DA2982B)
  - [docker-compose.yml](#h:6C55AE58)
    - [THREDDS Environment Variable Parameterization](#h:4D99AC45)
  - [Start the TDS](#h:71555497)
  - [Navigate to the TDS](#h:9BC953A7)



<a id="h:A57251FC"></a>

# Create a THREDDS VM on Jetstream


<a id="h:011CFB59"></a>

## Create a THREDDS VM on Jetstream

Create an `m1.medium` VM with the [Jetstream OpenStack API](../../openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `thredds-jetstream.unidata.ucar.edu`.


<a id="h:E1E7DBE4"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream ~/xsede-jetstream
```


<a id="h:704AF626"></a>

## Start TDS With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM with the TDS should be fairly easy. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](../../vm-init-readme.md).


<a id="h:1E5D6712"></a>

## TDS Configuration

```shell
mkdir -p ~/tdsconfig/
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/thredds/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
```


<a id="h:3F46F49F"></a>

### Supply Contact and Host Information in threddsConfig.xml

Edit the `~/tdsconfig/threddsConfig.xml` to supply contact and host institution by filling out the `contact` and `hostInstitution` XML elements. For example:

    <contact>
      <name>THREDDS Support</name>
      <organization>Unidata</organization>
      <email>support-thredds@unidata.ucar.edu</email>
    </contact>
    <hostInstitution>
      <name>Unidata</name>
      <webSite>http://www.unidata.ucar.edu/</webSite>
      <logoUrl>https://www.unidata.ucar.edu/software/thredds/v4.6/tds/images/unidataLogo.png</logoUrl>
      <logoAltText>Unidata</logoAltText>
    </hostInstitution>


<a id="h:E0771AED"></a>

## TDS log Directories


<a id="h:F83FDEE6"></a>

### Create log Directories

You will need Apache Tomcat and TDS log directories:

```shell
mkdir -p ~/logs/tds-tomcat/
mkdir -p ~/logs/tds/
```


<a id="h:7BF272F0"></a>

### Scour log Directories

Scour occasionally so the log directories do not fill up.

```shell
(crontab -l ; echo "59 0 * * * find ~/logs -regex '.*\.\(log\|txt\)' -type f -mtime +10 -exec rm -f {} \;")| crontab -
```


<a id="h:F043AB6A"></a>

## LDM Data Directory from idd-archiver Via NFS

The TDS will need access to the `/data/ldm/` directory from `idd-archiver` in order to serve data. Mount it via NFS on the `10.0.` network. For example, if `idd-archiver` is at `10.0.0.8`:

```shell
# create the NFS mount point
mkdir -p /data
mount 10.0.0.8:/data /data
```


<a id="h:437D2B38"></a>

### Ensure /data Availability Upon Machine Restart

You will want to ensure the NFS `/data` volume is available with the help of `fstab`.

```shell
echo 10.0.0.8:/data    /data   nfs rsize=32768,wsize=32768,timeo=14,intr | tee --append /etc/fstab > /dev/null
```


<a id="h:C5008DD9"></a>

## SSL Certificate

In the `~/xsede-jetstream/vms/thredds/files/` directory, generate a self-signed certificate with `openssl` (or better yet, obtain a real certificate from a certificate authority).

```shell
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/xsede-jetstream/vms/thredds/files/ssl.key \
  -out ~/xsede-jetstream/vms/thredds/files/ssl.crt
```


<a id="h:68B4119B"></a>

## Ports 80, 443 and 8443

[Open port](../../openstack/readme.md) `80` on the THREDDS VM via OpenStack. Port `80` requests will be forwarded to `8080` inside the THEREDDS Docker container. In addition, open ports `443` and `8443` for SSL and communication from the TDM.


<a id="h:0DA2982B"></a>

## THREDDS Data Manager (TDM)

The [TDM](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) is an application that works in conjunction with the TDS. It creates indexes for GRIB data as a background process, and notifies the TDS via port `8443` when data have been updated or changed. Because the TDM needs to **write** data, and NFS tuning concerns, in the present configuration, we have the TDM running on the `idd-archiver-jetstream` VM.


<a id="h:6C55AE58"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file that looks like:

```yaml
###
# THREDDS
###
version: '3'

services:
  thredds-production:
    image: unidata/thredds-docker:latest
    container_name: thredds
    # restart: always
    ports:
      - "80:8080"
      - "443:8443"
      - "8443:8443"
    volumes:
      - ~/logs/tds-tomcat/:/usr/local/tomcat/logs/
      - ~/logs/tds/:/usr/local/tomcat/content/thredds/logs/
      # ssl certs, keys not in version control, see readme.md
      - ./files/ssl.crt:/usr/local/tomcat/conf/ssl.crt
      - ./files/ssl.key:/usr/local/tomcat/conf/ssl.key
      - ./files/server.xml:/usr/local/tomcat/conf/server.xml
      - ./files/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml
      - ./files/tdsCat.css:/usr/local/tomcat/webapps/thredds/tdsCat.css
      - ./files/folder.gif:/usr/local/tomcat/webapps/thredds/folder.gif
      - ./files/index.jsp:/usr/local/tomcat/webapps/ROOT/index.jsp
      - /data/:/data/
      - ~/tdsconfig/:/usr/local/tomcat/content/thredds
    env_file:
      - "compose${THREDDS_COMPOSE_ENV_LOCAL}.env"
```


<a id="h:4D99AC45"></a>

### THREDDS Environment Variable Parameterization

You can provide additional THREDDS parameterization via the `compose.env` file referenced in the `docker-compose.yml` file.

```shell
### THREDDS related environment variables

# TDS Content root

# Paremeterization of the TDS_CONTENT_ROOT_PATH is probably not needed here
# since paremeterization can already achieved through the docker-compose.yml but
# here it is anyway

TDS_CONTENT_ROOT_PATH=/usr/local/tomcat/content

# The minimum and maximum Java heap space memory to be allocated to the TDS

THREDDS_XMX_SIZE=4G

THREDDS_XMS_SIZE=4G

# See https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid

TOMCAT_USER_ID=1000

TOMCAT_GROUP_ID=1000
```


<a id="h:71555497"></a>

## Start the TDS

Once you have done the work of setting up THREDDS related directories in the way you like,

```shell
docker-compose up -d
```

to start the TDS


<a id="h:9BC953A7"></a>

## Navigate to the TDS

In a web browser, navigate to [http://thredds-jetstream.unidata.ucar.edu/thredds/catalog.html](http://thredds-jetstream.unidata.ucar.edu/thredds/catalog.html) to see if is running.
