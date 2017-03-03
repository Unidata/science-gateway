#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name secgroup name] [-p, --port secgroup port] -- 
script to setup secgroups.:\n
    -h  show this help text\n
    -l, --list secgroup list\n
    -n, --name secgroup name\n
    -p, --port secgroup port\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            SECGROUP_NAME="$2"
            shift # past argument
            ;;
        -p|--port)
            SECGROUP_PORT="$2"
            shift # past argument
            ;;
        -l|--list)
            nova secgroup-list
            exit
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z ${SECGROUP_NAME+x} ];
  then
      echo "Must supply a secgroup name:" 
      echo -e $usage
      exit 1
fi

if [ -z ${SECGROUP_PORT+x} ];
   then
      echo "Must supply a secgroup port:" 
      echo -e $usage
      exit 1
fi

nova secgroup-create global-${SECGROUP_NAME} "${SECGROUP_NAME} enabled"
nova secgroup-add-rule global-${SECGROUP_NAME} tcp ${SECGROUP_PORT} ${SECGROUP_PORT} 0.0.0.0/0
nova secgroup-add-rule global-${SECGROUP_NAME} icmp -1 -1 0.0.0.0/0
nova secgroup-list
