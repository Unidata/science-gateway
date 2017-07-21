#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

usage="$(basename "$0") [-h] [-m, --mount device mount (e.g., /dev/sdb)] [-d, --directory directory to attach to device mount]  -- 
Convenience script to mount new volumes. Careful! Your data will be deleted if your volume contains data!:\n
    -h  show this help text\n
    -m, --mount device mount.\n
    -d, --directory directory\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -m|--mount)
            MOUNT="$2"
            shift # past argument
            ;;
        -d|--directory)
            DIRECTORY="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$MOUNT" ];
  then
      echo "Must supply a device mount name:" 
      echo -e $usage
      exit 1
fi

if [ -z "$DIRECTORY" ];
   then
      echo "Must supply a directory name to attach to mount:" 
      echo -e $usage
      exit 1
fi

mkdir -p $DIRECTORY
fdisk -l $MOUNT
mkfs.ext4 $MOUNT
mount $MOUNT $DIRECTORY
echo "Ensure the $DIRECTORY is chowned correctly"
echo "Ensure /etc/fstab is to your liking in order to have the data volume available upon reboot"
