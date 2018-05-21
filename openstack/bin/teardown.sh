#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name vm name] [-ip, --ip ip address] -- 
script to teardown VMs.:\n
    -h  show this help text\n
    -n, --name vm name.\n
    -ip, --ip vm ip number\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            VM_NAME="$2"
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
      openstack server list
      exit 1
fi

MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

openstack server stop ${MACHINE_NAME}

if [ -v "$IP" ];
   then
       openstack server remove floating ip ${MACHINE_NAME} ${IP}
fi

openstack server delete ${MACHINE_NAME}
