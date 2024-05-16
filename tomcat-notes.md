- [Unidata Science Gateway Notes on Tomcat](#h-860CB937)
  - [301 Redirection](#h-3547241C)
    - [server.xml Connector Element](#h-6C1D382D)
    - [server.xml Engine Element](#h-0B3CE066)
    - [rewrite.config file](#h-B115F909)



<a id="h-860CB937"></a>

# Unidata Science Gateway Notes on Tomcat

We use Tomcat quite a bit on the Unidata Science Gateway (USG) in a few different capacities via the [Unidata Tomcat Docker container](https://github.com/Unidata/tomcat-docker):

-   [THREDDS Server](https://tds.scigw.unidata.ucar.edu/thredds/catalog/catalog.html)
-   [NEXRAD THREDDS Server](https://tds-nexrad.scigw.unidata.ucar.edu/thredds/catalog/catalog.html)
-   [RAMADDA](https://ramadda.scigw.unidata.ucar.edu/repository)

This document is a loose collection of notes concerning the use of Tomcat on the USG.


<a id="h-3547241C"></a>

## 301 Redirection

In order to get redirection to work in Tomcat (e.g., thredds-aws.unidata.ucar.edu -> tds-nexrad.scigw.unidata.ucar.edu), there are a few details that have to be taken into account in `keystore.jks` and `server.xml`. First, the **valid** certificates for the old and new URLs must be present in the `.jks` [keystore file](https://github.com/Unidata/tomcat-docker?tab=readme-ov-file#certificate-from-ca) and referenced in `server.xml` in roughly the following manner (I've omitted a number of `Connector` element details for the sake of clarity).


<a id="h-6C1D382D"></a>

### server.xml Connector Element

```xml
<Connector port="8443"
           defaultSSLHostConfigName="_default_">
  <SSLHostConfig honorCipherOrder="true"
                 hostName="_default_"
                 disableSessionTickets="true">
    <Certificate certificateKeystoreFile="${catalina.base}/conf/keystore.jks"
                 certificateKeystorePassword="xxx"
                 certificateKeyAlias="tds-nexrad.scigw.unidata.ucar.edu"/>
  </SSLHostConfig>
  <SSLHostConfig honorCipherOrder="true"
                 hostName="thredds-aws.unidata.ucar.edu"
                 disableSessionTickets="true">
    <Certificate certificateKeystoreFile="${catalina.base}/conf/keystore.jks"
                 certificateKeystorePassword="xxx"
                 certificateKeyAlias="thredds-aws.unidata.ucar.edu"/>
  </SSLHostConfig>
</Connector>
```


<a id="h-0B3CE066"></a>

### server.xml Engine Element

Additionally, you'll need to augment the `Engine` element with the old and new host as well as `localhost` and the `RewriteValve` in the following manner (again omitting some details, e.g., logging for the sake of clarity):

```xml
<Engine name="Catalina" defaultHost="localhost">
  <Host name="thredds-aws.unidata.ucar.edu" appBase="webapps" createDirs="false"
        unpackWARs="true" autoDeploy="true">
    <Valve className="org.apache.catalina.valves.rewrite.RewriteValve" />
  </Host>
  <Host name="tds-nexrad.scigw.unidata.ucar.edu"  appBase="webapps"  createDirs="false"
        unpackWARs="true" autoDeploy="true">
  </Host>
  <Host name="localhost"  appBase="webapps"  createDirs="false"
        unpackWARs="true" autoDeploy="true">
  </Host>
</Engine>
```


<a id="h-B115F909"></a>

### rewrite.config file

Finally, you will need a `rewrite.config` file that is co-located to the `server.xml`:

```fundamental
RewriteCond %{HTTP_HOST} ^thredds-aws.unidata.ucar.edu$
RewriteRule ^/(.*)$ https://tds-nexrad.scigw.unidata.ucar.edu/$1 [R=301,L]
```
