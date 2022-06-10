#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# adde
echo /data		10.0.0.188(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
# thredds
echo /data		10.0.0.122(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
# ramadda
echo /data		10.0.0.143(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null

exportfs -a
service nfs-kernel-server start

update-rc.d nfs-kernel-server defaults
