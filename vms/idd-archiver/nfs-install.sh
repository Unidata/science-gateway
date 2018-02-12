#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo /data		10.0.0.18(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
echo /data		10.0.0.15(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
echo /data		10.0.0.11(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null
echo /data		10.0.0.10(rw,sync,no_subtree_check) | tee \
    --append /etc/exports > /dev/null

exportfs -a
service nfs-kernel-server start

update-rc.d nfs-kernel-server defaults
