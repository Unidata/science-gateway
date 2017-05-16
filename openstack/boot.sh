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

echo $usage

exit 1

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
      openstack server list
      exit 1
fi

if [ -z "$IP" ];
   then
      echo "Must supply an IP address:"
      echo -e $usage
      openstack floating ip list
      exit 1
fi

if [ -z "$IMAGE_NAME" ];
   then
      IMAGE_NAME=afbf353a-f0b5-4598-89bd-38acdc6f4b10
      echo "No image name supplied so going with ${IMAGE_NAME}."
fi

# OS_PROJECT_NAME is defined in openrc.sh
MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

openstack server create ${MACHINE_NAME} \
  --flavor ${VM_SIZE} \
  --image ${IMAGE_NAME} \
  --key-name ${KEY_NAME} \
  --security-groups global-ssh-22 \
  --nic net-name=${OS_PROJECT_NAME}-api-net

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

openstack server add floating ip ${MACHINE_NAME} ${IP}
