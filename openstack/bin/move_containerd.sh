#!/bin/bash

# On JupyterHub with Kubernetes GPU clusters, /var/lib/containerd can get
# overloaded on the individual VM nodes. Theoretically, this should be handled
# by Kubernetes, but this is not always the case in practice. This script moves
# /var/lib/containerd onto an externally mounted volume (e.g., 150GBs) as a stop
# gap measure that you have already set up. See here:
# https://github.com/Unidata/science-gateway/blob/master/openstack/readme.md#h-9BEEAB97.
# This script probably will not be needed in the future as this situation will
# hopefully get resolved.

# Variables
external_disk="/dev/sdb"
new_mount_point="/mnt/new_containerd"
old_containerd_dir="/var/lib/containerd"
backup_containerd_dir="/var/lib/containerd_backup"

echo "Stopping containerd service..."
systemctl stop containerd || { echo "Failed to stop containerd"; exit 1; }

read -p "Are you sure you want to format $external_disk? This will erase all data on it. (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Operation cancelled."
    exit 1
fi

echo "Mounting $external_disk to $new_mount_point..."
mkdir -p $new_mount_point
fdisk -l $external_disk
mkfs.ext4 $external_disk || { echo "Failed to format $external_disk"; exit 1; }
mount $external_disk $new_mount_point || \
    { echo "Failed to mount $external_disk"; exit 1; }

echo "Copying data from $old_containerd_dir to $new_mount_point..."
rsync -avz $old_containerd_dir/ $new_mount_point/ || \
    { echo "Failed to copy data"; exit 1; }

echo "Renaming $old_containerd_dir to $backup_containerd_dir..."
mv $old_containerd_dir $backup_containerd_dir || \
    { echo "Failed to rename $old_containerd_dir"; exit 1; }

echo "Creating a symbolic link from $old_containerd_dir to $new_mount_point..."
ln -s $new_mount_point $old_containerd_dir || \
    { echo "Failed to create symbolic link"; exit 1; }

# Restart the containerd service
echo "Restarting containerd service..."
systemctl start containerd || { echo "Failed to start containerd"; exit 1; }

echo "Process complete. Please verify the functionality of containerd."

# Now take care of /etc/fstab

# Find the UUID for /dev/sdb
UUID=$(findmnt -n -o UUID $new_mount_point)

# Check if UUID was found
if [ -z "$UUID" ]; then
    echo "UUID for $external_disk not found."
    exit 1
fi

echo "Append the UUID for $new_mount_point"
echo "UUID=$UUID $new_mount_point ext4 defaults 1 1" | sudo tee -a /etc/fstab

echo "/etc/fstab modified. Please verify contents of /etc/fstab."
