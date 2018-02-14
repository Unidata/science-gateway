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

if [ -z "$IP" ];
   then
      echo "Must supply an IP address:"
      echo -e $usage
      openstack server list
      exit 1
fi

MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

openstack server stop ${MACHINE_NAME}

openstack server remove floating ip ${MACHINE_NAME} ${IP}

openstack server delete ${MACHINE_NAME}
