- [Create a THREDDS AWS Nexrad VM on Jetstream](#h-4D049C67)
  - [Create a THREDDS VM on Jetstream](#h-06E230D1)
  - [Clone the science-gateway Repository](#h-966B0207)
  - [Build the AWS Nexrad TDS Docker Container](#h-154BBC9F)
  - [Start TDS With Docker and docker-compose](#h-74EEEE2C)
  - [TDS Configuration](#h-717697EB)
    - [Supply Contact and Host Information in threddsConfig.xml](#h-615B0684)
  - [TDS log Directories](#h-F52D01A2)
    - [Create log Directories](#h-99E9AD76)
  - [S3Objects Directory](#h-F6EBEBDF)
    - [Create S3Objects Directory](#h-763C22DA)
    - [Scour S3Objects Directory](#h-483C35F9)
  - [SSL Certificate](#h-0B00E7AE)
  - [Ports 80, 443 and 8443](#h-1541998B)
  - [docker-compose.yml](#h-B1EEBC0A)
    - [THREDDS Environment Variable Parameterization](#h-F0A8F4C2)
  - [Start the TDS](#h-DF4BC998)
  - [Navigate to the TDS](#h-628E2897)
  - [Blocking IPs That Are Filling up the Cache](#h-9906607B)



<a id="h-4D049C67"></a>

# Create a THREDDS AWS Nexrad VM on Jetstream


<a id="h-06E230D1"></a>

## Create a THREDDS VM on Jetstream

Create an `m1.large` VM with the [Jetstream OpenStack API](../../openstack/readme.md). Work with Unidata system administrator staff to have this VM's IP address resolve to `thredds-aws.unidata.ucar.edu`


<a id="h-966B0207"></a>

## Clone the science-gateway Repository

We will be making heavy use of the `Unidata/science-gateway` git repository.

```shell
git clone https://github.com/Unidata/science-gateway ~/science-gateway
```


<a id="h-154BBC9F"></a>

## Build the AWS Nexrad TDS Docker Container

From the `~/science-gateway/vms/thredds-aws` directory:

```shell
docker build -t unidata/nexrad-tds-docker:latest .
```


<a id="h-74EEEE2C"></a>

## Start TDS With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM with the TDS should be fairly easy. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](../../vm-init-readme.md).


<a id="h-717697EB"></a>

## TDS Configuration

```shell
mkdir -p ~/tdsconfig/
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/awsL2/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
```


<a id="h-615B0684"></a>

### Supply Contact and Host Information in threddsConfig.xml

Edit the `~/tdsconfig/threddsConfig.xml` to supply contact and host institution by filling out the `contact` and `hostInstitution` XML elements. For example:

```
<contact>
  <name>THREDDS Support</name>
  <organization>Unidata</organization>
  <email>support-thredds@unidata.ucar.edu</email>
</contact>
<hostInstitution>
  <name>Unidata</name>
  <webSite>http://www.unidata.ucar.edu/</webSite>
  <logoUrl>https://ral.ucar.edu/sites/default/files/public/images/project/Unidata_logo_vertical_400x400_alpha.png</logoUrl>
  <logoAltText>Unidata</logoAltText>
</hostInstitution>
```


<a id="h-F52D01A2"></a>

## TDS log Directories


<a id="h-99E9AD76"></a>

### Create log Directories

You will need Apache Tomcat and TDS log directories:

```shell
mkdir -p /logs/tds-tomcat/
mkdir -p /logs/tds/
```


<a id="h-F6EBEBDF"></a>

## S3Objects Directory


<a id="h-763C22DA"></a>

### Create S3Objects Directory

Files served out of S3 are first written to local file system, then served via THREDDS.

```shell
mkdir -p ~/S3Objects
```


<a id="h-483C35F9"></a>

### Scour S3Objects Directory

```shell
(crontab -l ; echo "*/5 * * * * find ~/S3Objects -mindepth 1 -mmin +15 -delete")| crontab -
```


<a id="h-0B00E7AE"></a>

## SSL Certificate

In the `~/science-gateway/vms/thredds-aws/files/` directory, generate a self-signed certificate with `openssl` (or better yet, obtain a real certificate from a certificate authority).

```shell
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/science-gateway/vms/thredds-aws/files/ssl.key \
  -out ~/science-gateway/vms/thredds-aws/files/ssl.crt
```


<a id="h-1541998B"></a>

## Ports 80, 443 and 8443

[Open port](../../openstack/readme.md) `80` on the THREDDS VM via OpenStack. Port `80` requests will be forwarded to `8080` inside the THEREDDS Docker container. In addition, open ports `443` and `8443` for SSL and communication from the TDM.


<a id="h-B1EEBC0A"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file that looks like:

```yaml
###
# THREDDS
###
version: '3'

services:
  thredds-production:
    image: unidata/nexrad-tds-docker:latest
    container_name: thredds
    # restart: always
    ports:
      - "80:8080"
      - "443:8443"
      - "8443:8443"
    volumes:
      - /logs/tds-tomcat/:/usr/local/tomcat/logs/
      - /logs/tds/:/usr/local/tomcat/content/thredds/logs/
      # ssl certs, keys not in version control, see readme.md
      - ./files/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml
      - ./files/tdsCat.css:/usr/local/tomcat/webapps/thredds/tdsCat.css
      - ./files/folder.gif:/usr/local/tomcat/webapps/thredds/folder.gif
      - ./files/index.jsp:/usr/local/tomcat/webapps/ROOT/index.jsp
      # HTTPS
      - ./files/keystore.jks:/usr/local/tomcat/conf/keystore.jks
      - ./files/server.xml:/usr/local/tomcat/conf/server.xml
      # AWS TDS Nexrad server
      - ~/tdsconfig/:/usr/local/tomcat/content/thredds/
      - ~/S3Objects/:/usr/local/tomcat/temp/S3Objects/
      - ~/files/credentials:/usr/local/tomcat/.aws/credentials
    env_file:
      - "compose${THREDDS_COMPOSE_ENV_LOCAL}.env"
```


<a id="h-F0A8F4C2"></a>

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


<a id="h-DF4BC998"></a>

## Start the TDS

Once you have done the work of setting up THREDDS related directories in the way you like,

```shell
docker-compose up -d
```

to start the TDS


<a id="h-628E2897"></a>

## Navigate to the TDS

In a web browser, navigate to [https://thredds-aws.unidata.ucar.edu/thredds/catalog.html](https://thredds-aws.unidata.ucar.edu/thredds/catalog.html) to see if is running.


<a id="h-9906607B"></a>

## Blocking IPs That Are Filling up the Cache

You will sometimes find that data scraper bots are overloading the TDS Radar server which leads to the cache filling up the disk. One way to mitigate this is to block IPs via `iptables`. To find the offending IP ranges, navigate to the `/logs/tds-tomcat` looking for user agents like "spider", "oc4", etc. in the Tomcat access logs.

```shell
grep -i -h -E "oc4|rain|spider"  access*  | awk '{print $1}' | sort | uniq | awk -F "." '{print $1 "." $2}' | sort -n | uniq
```

Work with Unidata system administration staff to block the IP ranges with something like the snippet below. Note that the rule is being inserted into the `DOCKER-USER` chain with the `-I` option which is important to get `iptables` to work with the THREDDS Docker container.

```shell
sudo iptables -I DOCKER-USER -s xx.xxx.0.0/16 -j DROP
# etc.
```

To see how these rules take affect you can:

```shell
sudo iptables -L DOCKER-USER -n -v
```

which will yield something like:

```shell
Chain DOCKER-USER (1 references)
 pkts bytes target     prot opt in     out     source               destination
22404 1344K DROP       all  --  *      *       xx.22.0.0/16         0.0.0.0/0
 134K 8044K DROP       all  --  *      *       xx.128.0.0/16        0.0.0.0/0
 270K   16M DROP       all  --  *      *       xx.249.0.0/16        0.0.0.0/0
 265K   16M DROP       all  --  *      *       xx.225.0.0/16        0.0.0.0/0
30892 1606K DROP       all  --  *      *       xx.199.0.0/16        0.0.0.0/0
60216 3613K DROP       all  --  *      *       xx.204.182.0/24      0.0.0.0/0
  50M  107G RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```
