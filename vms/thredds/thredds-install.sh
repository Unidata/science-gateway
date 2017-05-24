#!/bin/bash
git clone https://github.com/Unidata/TdsConfig ~/TdsConfig

mkdir -p ~/tdsconfig/
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/idd/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/

mkdir -p ~/logs/tds-tomcat/
mkdir -p ~/logs/tds/

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/xsede-jetstream/vms/thredds/files/ssl.key \
  -out ~/xsede-jetstream/vms/thredds/files/ssl.crt
