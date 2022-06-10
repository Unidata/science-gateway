#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

###
# Add IPs of machines which will access NFS server
###

# adde
echo /data		10.0.0.188(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
# thredds
echo /data		10.0.0.122(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
# ramadda
echo /data		10.0.0.143(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null

###
# Start NFS server
###

exportfs -a
# Ensure server starts on reboot
systemctl enable nfs-server.service
systemctl start nfs-server.service
