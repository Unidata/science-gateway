#!/bin/bash
git clone https://github.com/Unidata/TdsConfig ~/TdsConfig

mkdir -p ~/etc
cp ~/xsede-jetstream/vms/idd-archiver/etc/* ~/etc/

mkdir -p /tmp/tdsconfig/ ~/etc/TDS
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/idd/config.zip -O /tmp/tdsconfig/config.zip
unzip /tmp/tdsconfig/config.zip -d /tmp/tdsconfig/
cp -r /tmp/tdsconfig/pqacts/* ~/etc/TDS
rm -rf /tmp/tdsconfig

# in place change of logs dir w/ sed
sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
    ~/etc/TDS/util/ldmfile.sh

chmod +x ~/etc/TDS/util/ldmfile.sh

mkdir -p /data/queues

mkdir -p /data/logs/ldm
