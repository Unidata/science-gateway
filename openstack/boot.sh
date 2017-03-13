#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name vm name] [-k, --key key name] \n
    [-s, --size vm size] [-ip, --ip ip address] -- script to create VMs.:\n
    -h  show this help text\n
    -n, --name vm name\n
    -k, --key key name\n
    -s, --size vm size\n
    -net, --netname network name or network UUID\n
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
        -net|--netname)
            NET_NAME="$2"
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

if [ -z ${VM_NAME+x} ];
  then
      echo "Must supply a vm name:" 
      echo -e $usage
      exit 1
fi

if [ -z ${KEY_NAME+x} ];
  then
      echo "Must supply a key name:" 
      echo -e $usage
      exit 1
fi

if [ -z ${VM_SIZE+x} ];
   then
      echo "Must supply a vm size:" 
      echo -e $usage
      nova flavor-list
      exit 1
fi

if [ -z ${IP+x} ];
   then
      echo "Must supply an IP address:"
      echo -e $usage
      nova floating-ip-list
      exit 1
fi

if [ -z ${NET_NAME+x} ];
   then
      NET_NAME=${OS_PROJECT_NAME}-api-net
      echo "No network name supplied to going with ${NET_NAME}." 
fi

# OS_PROJECT_NAME is defined in openrc.sh
MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

# The image name below is hard-coded. Select from one of these image names which you can
# get with `glance image-list | grep -i featured`
# 
# |--------------------------------------+-----------------------------------------------------|
# | UUID                                 | Name                                                |
# |--------------------------------------+-----------------------------------------------------|
# | 21c904b7-b7b0-4f30-bb99-09aa2412bc3c | JS-API-Featured-CentOS6-Feb-10-2017                 |
# | 736e206d-9c2c-4369-88db-8c3293bd2ad7 | JS-API-Featured-Centos7-Feb-7-2017                  |
# | 58aebfd2-6ce4-4bcf-8da2-2a9bea6beb2f | JS-API-Featured-CentOS7-Intel-Developer-Feb-20-2017 |
# | b8c5b987-7221-48d8-adb2-27fdcfbb38ba | JS-API-Featured-Ubuntu14-Feb-23-2017                |
# | afbf353a-f0b5-4598-89bd-38acdc6f4b10 | JS-API-Featured-Ubuntu16-Feb-9-2017                 |
# |--------------------------------------+-----------------------------------------------------|
# 

nova boot ${MACHINE_NAME} \
  --flavor ${VM_SIZE} \
  --image afbf353a-f0b5-4598-89bd-38acdc6f4b10 \
  --key-name ${KEY_NAME} \
  --security-groups global-ssh-22 \
  --nic net-name=${NET_NAME}

# give chance for VM to fire up
echo sleep 30 for seconds while VM fires up
sleep 30

# This section leaves something to be desired, obviously. The options should be
# parameterized from the command line. Comment in/out for the ports you need
# open.  Also see unidata-ports.sh.

# nova add-secgroup ${MACHINE_NAME} global-http-80
# nova add-secgroup ${MACHINE_NAME} global-ldm-388
# nova add-secgroup ${MACHINE_NAME} global-adde-112
# nova add-secgroup ${MACHINE_NAME} global-ssl-443
# nova add-secgroup ${MACHINE_NAME} global-tomcat-http-8080
# nova add-secgroup ${MACHINE_NAME} global-tomcat-ssl-8443

# Associate your VM with an IP

nova floating-ip-associate ${MACHINE_NAME} ${IP}
