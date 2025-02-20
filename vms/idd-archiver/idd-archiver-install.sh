#!/bin/bash
git clone https://github.com/Unidata/TdsConfig ~/TdsConfig

mkdir -p ~/etc
cp ~/science-gateway/vms/idd-archiver/etc/* ~/etc/

mkdir -p ~/tdsconfig/ ~/etc/TDS
wget https://artifacts.unidata.ucar.edu/repository/downloads-tds-config/thredds/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS

# in place change of logs dir w/ sed
sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
    ~/etc/TDS/util/ldmfile.sh

chmod +x ~/etc/TDS/util/ldmfile.sh

mkdir -p /data/ldm/queues

mkdir -p /data/ldm/logs/

mkdir -p ~/logs/tdm

curl -SL  \
     https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.13/tdmFat-4.6.13.jar \
     -o ~/logs/tdm/tdm.jar
curl -SL https://raw.githubusercontent.com/Unidata/tdm-docker/master/tdm.sh \
     -o ~/logs/tdm/tdm.sh
chmod +x  ~/logs/tdm/tdm.sh
