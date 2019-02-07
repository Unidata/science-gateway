mkdir -p ~/tdsconfig/
wget http://unidata-tds.s3.amazonaws.com/tdsConfig/awsL2/config.zip -O ~/tdsconfig/config.zip
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/

mkdir -p ~/S3Objects/

mkdir -p ~/logs/tds-tomcat/
mkdir -p ~/logs/tds/

(crontab -l ; echo "59 0 * * * find ~/logs -regex '.*\.\(log\|txt\)' -type f -mtime +10 -exec rm -f {} \;")| crontab -
(crontab -l ; echo "*/5 * * * * find ~/S3Objects -mindepth 1 -mmin +15 -delete")| crontab -

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/xsede-jetstream/vms/thredds-aws/files/ssl.key \
  -out ~/xsede-jetstream/vms/thredds-aws/files/ssl.crt
