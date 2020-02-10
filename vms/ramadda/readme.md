- [Creating a RAMADDA VM on Jetstream](#h-07FD791D)
  - [Create a RAMADDA VM on Jetstream](#h-F4023EC5)
  - [Clone the xsede-jetstream Repository](#h-968FA51C)
  - [Start RAMADDA With Docker and docker-compose](#h-2E18E909)
  - [/repository Directory](#h-2F1A5636)
  - [Create RAMADDA default password](#h-D5095E2A)
  - [RAMADDA log Directories](#h-1C3FF741)
    - [Create log Directories](#h-DABCF6E2)
    - [Scour log Directories](#h-1121D213)
  - [LDM Data Directory from idd-archiver Via NFS](#h-85431E50)
  - [Ensure /repository and /data Availability Upon Machine Restart](#h-6423976C)
    - [/data NFS Mounted Volume](#h-286B798E)
  - [Port 80](#h-404D9595)
  - [docker-compose.yml](#h-7E683535)
    - [RAMADDA Environment Variable Parameterization](#h-704211AA)
  - [SSL](#h-4DC08484)
  - [Start RAMADDA](#h-224A9684)
  - [Navigate to RAMADDA](#h-81FED1EC)
  - [Access RAMADDA with the Unidata IDV](#h-73BB6227)
    - [RAMADDA IDV Plugin](#h-3CCEFC0F)
    - [RAMADDA Server Side Views](#h-C8481694)
    - [RAMADDA Catalog Views from the IDV](#h-589449E2)



<a id="h-07FD791D"></a>

# Creating a RAMADDA VM on Jetstream


<a id="h-F4023EC5"></a>

## Create a RAMADDA VM on Jetstream

Create an `m1.medium` VM with the [Jetstream OpenStack API](../../openstack/readme.md). [Create and attach](../../openstack/readme.md) a 100GB `/repository` volume to that VM. Work with Unidata system administrator staff to have this VM's IP address resolve to `ramadda.scigw.unidata.ucar.edu`.


<a id="h-968FA51C"></a>

## Clone the xsede-jetstream Repository

We will be making heavy use of the `Unidata/xsede-jetstream` git repository.

```shell
git clone https://github.com/Unidata/xsede-jetstream
```


<a id="h-2E18E909"></a>

## Start RAMADDA With Docker and docker-compose

With the help of Docker and `docker-compose`, starting a VM with the RAMADDA content management system should be fairly easy. There are a few directories you will need to map from outside to within the container. [See here to install Docker and docker-compose](../../vm-init-readme.md).


<a id="h-2F1A5636"></a>

## /repository Directory

The `/repository` directory should be a fairly beefy data volume (e.g., 100 GBs) or however much data you anticipate your RAMADDA users will consume. [See here if creating data volumes via the JetStream OpenStack API](../../openstack/readme.md).


<a id="h-D5095E2A"></a>

## Create RAMADDA default password

[When starting RAMADDA for the first time](#h-224A9684), you must have a `password.properties` file in the RAMADDA home directory which is `/repository/`. See [RAMADDA documentation](https://ramadda.org//repository/userguide/toc.html) for more details on setting up RAMADDA. Here is a `pw.properties` file to get you going. Change password below to something more secure!

```shell
# Create RAMADDA default password

echo ramadda.install.password=changeme! | tee --append \
  /repository/pw.properties > /dev/null
```


<a id="h-1C3FF741"></a>

## RAMADDA log Directories


<a id="h-DABCF6E2"></a>

### Create log Directories

You will need an Apache Tomcat and RAMADDA log directories:

```shell
mkdir -p ~/logs/ramadda-tomcat/
mkdir -p ~/logs/ramadda/
```


<a id="h-1121D213"></a>

### Scour log Directories

Scour occasionally so the log directories do not fill up.

```shell
(crontab -l ; echo "59 0 * * * find ~/logs -regex '.*\.\(log\|txt\)' -type f -mtime +10 -exec rm -f {} \;")| crontab -
```


<a id="h-85431E50"></a>

## LDM Data Directory from idd-archiver Via NFS

If you plan on employing the [server-side view capability of RAMADDA](https://ramadda.org//repository/userguide/developer/filesystem.html) which is quite useful for monitoring your LDM data feeds, you will have to make that directory (e.g., `/data/ldm/`) available to the RAMADDA VM and Docker container. In our present configuration, that directory is on the `idd-archiver` machine so you need to mount it via NFS on the `10.0.` network. For example, if `idd-archiver` is at `10.0.0.4`:

```shell
# create the NFS mount point
sudo mkdir -p /data
sudo mount 10.0.0.4:/data /data
```


<a id="h-6423976C"></a>

## Ensure /repository and /data Availability Upon Machine Restart

[Ensure the `/repository` volume availability upon machine restart](../../openstack/readme.md).

```shell
sudo echo UUID=2c571c6b-c190-49bb-b13f-392e984a4f7e	 /repository	ext4	defaults	1	 1 | tee --append /etc/fstab > /dev/null
```


<a id="h-286B798E"></a>

### /data NFS Mounted Volume

In addition, you will want to ensure the NFS `/data` volume is also available with the help of `fstab`.

```shell
sudo echo 10.0.0.4:/data    /data   nfs rsize=32768,wsize=32768,timeo=14,intr | tee --append /etc/fstab > /dev/null
```


<a id="h-404D9595"></a>

## Port 80

[Open port](../../openstack/readme.md) `80` on the RAMADDA VM via OpenStack. Port `80` requests will be forwarded to `8080` inside the RAMADDA Docker container.


<a id="h-7E683535"></a>

## docker-compose.yml

Based on the directory set we have defined, the `docker-compose.yml` file will look something like:

```yaml
version: '3'

services:

  ramadda:
    image: unidata/ramadda-docker:latest
    container_name: ramadda
    # restart: always
    ports:
      - "80:8080"
      - "443:8443"
      - "8443:8443"
    volumes:
      - /repository/:/data/repository/
      - /data/ldm/:/data/ldm/
      - ~/logs/ramadda-tomcat/:/usr/local/tomcat/logs/
      - ~/logs/ramadda/:/data/repository/logs/
      - ./files/index.jsp:/usr/local/tomcat/webapps/ROOT/index.jsp
      # Everything below is required for https
      - ./files/server.xml:/usr/local/tomcat/conf/server.xml
      - ./files/web.xml:/usr/local/tomcat/conf/web.xml
      - ./files/keystore.jks:/usr/local/tomcat/conf/keystore.jks
      - ./files/repository.properties:/usr/local/tomcat/conf/repository.properties
    env_file:
      - "compose.env"
```


<a id="h-704211AA"></a>

### RAMADDA Environment Variable Parameterization

You can provide additional RAMADDA parameterization via the `compose.env` file referenced in the `docker-compose.yml` file.

```shell
# See https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid

TOMCAT_USER_ID=1000

TOMCAT_GROUP_ID=1000
```


<a id="h-4DC08484"></a>

## SSL

We are moving towards an HTTPS only world. As such, you'll want to run a [RAMADDA production server on HTTPS](https://github.com/Unidata/tomcat-docker#h-E0520F81). [Once RAMADDA is running](#h-224A9684), you'll want to configure RAMADDA for SSL via the administrative account. There is documentation about this topic [here](http://ramadda.org/repository/userguide/installing.html#ssl). The main thing appears to be the Admin → Settings → Site and Contact Information, ensure "Force all connections to be secure" is checked. The `repository.properties` file that is referenced in the `docker-compose.yml` should be configured properly for SSL.


<a id="h-224A9684"></a>

## Start RAMADDA

Once you have done the work of setting up RAMADDA related directories in the way you like,

```shell
docker-compose up -d
```

to start RAMADDA.


<a id="h-81FED1EC"></a>

## Navigate to RAMADDA

In a web browser, navigate to [https://ramadda.scigw.unidata.ucar.edu/repository](https://ramadda.scigw.unidata.ucar.edu/repository). If this is the first time you are accessing RAMADDA, RAMADDA will guide you through a server configuration workflow. You will be prompted for the repository password [you defined earlier](#h-D5095E2A).


<a id="h-73BB6227"></a>

## Access RAMADDA with the Unidata IDV

RAMADDA has good integration with the [Unidata Integrated Data Viewer (IDV)](http://www.unidata.ucar.edu/software/idv/) and the two technologies work well together.


<a id="h-3CCEFC0F"></a>

### RAMADDA IDV Plugin

IDV users may wish to install the [RAMADDA IDV plugin](http://www.unidata.ucar.edu/software/idv/docs/workshop/savingstate/Ramadda.html) to publish IDV bundles to RAMADDA.


<a id="h-C8481694"></a>

### RAMADDA Server Side Views

RAMADDA also has access to the LDM `/data/` directory so you may want to set up [server-side view of this part of the file system](https://ramadda.org//repository/userguide/developer/filesystem.html). This is a two step process where administrators go to the Admin, Access, File Access menu item and lists the allowed directories they potentially wish to expose via RAMADDA. Second, the users are now capable of creating a "Server Side" Files with the usual RAMADDA entry creation mechanisms.


<a id="h-589449E2"></a>

### RAMADDA Catalog Views from the IDV

Finally, you can enter this catalog URL in the IDV dashboard to examine data holdings shared bundles, etc. on RAMADDA. For example, <https://ramadda.scigw.unidata.ucar.edu/repository?output=thredds.catalog>.
