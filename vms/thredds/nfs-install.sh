#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# create the NFS mount point
mkdir -p /data
mount 10.0.0.4:/data /data

echo 10.0.0.4:/data    /data   nfs rsize=32768,wsize=32768,timeo=14,intr | tee --append /etc/fstab > /dev/null
