#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name vm name] [-k, --key key name] \n
    [-s, --size vm size] [-i, --image image UID] [-ip, --ip ip address] \n
    -- script to create VMs:\n
    -h  show this help text\n
    -n, --name vm name\n
    -k, --key key name\n
    -s, --size vm size\n
    -i, --image image UID\n
    -ip, --ip vm ip number\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            VM_NAME="$2"
            shift # past argument
            ;;
        -k|--key)
            KEY_NAME="$2"
            shift # past argument
            ;;
        -s|--size)
            VM_SIZE="$2"
            shift # past argument
            ;;
        -i|--image)
            IMAGE_NAME="$2"
            shift # past argument
            ;;
        -ip|--ip)
            IP="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$VM_NAME" ];
  then
      echo "Must supply a vm name:" 
      echo -e $usage
      exit 1
fi

if [ -z "$KEY_NAME" ];
  then
      echo "Must supply a key name:" 
      echo -e $usage
      exit 1
fi

if [ -z "$VM_SIZE" ];
   then
      echo "Must supply a vm size:" 
      echo -e $usage
      openstack flavor list
      exit 1
fi

if [ -z "$IMAGE_NAME" ];
then
      # Grab an Ubuntu 16 Featured Image
    IMAGE_NAME=$(openstack image list | grep -i featured | grep -i ubuntu16 \
                     | awk 'BEGIN { FS = "|" } ; { print $2 }' | tail -1)
      echo "No image name supplied so going with ${IMAGE_NAME}."
fi

# OS_PROJECT_NAME is defined in openrc.sh
MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

# obtained through openstack network list
NETWORK_ID=TG-ATM160027-api-net

openstack server create ${MACHINE_NAME} \
  --flavor ${VM_SIZE} \
  --image ${IMAGE_NAME} \
  --key-name ${KEY_NAME} \
  --security-group global-ssh-22 \
  --nic net-id=${NETWORK_ID}

# give chance for VM to fire up
echo sleep 30 for seconds while VM fires up
sleep 30

# This section leaves something to be desired, obviously. The options should be
# parameterized from the command line. Comment in/out for the ports you need
# open.  Also see unidata-ports.sh.

# openstack server add security group ${MACHINE_NAME} global-www
# openstack server add security group ${MACHINE_NAME} global-ldm-388
# openstack server add security group ${MACHINE_NAME} global-adde-112
# openstack server add security group ${MACHINE_NAME} global-tomcat

# Associate your VM with an IP

if [ -v "$IP" ];
   then
       openstack server add floating ip ${MACHINE_NAME} ${IP}
fi


