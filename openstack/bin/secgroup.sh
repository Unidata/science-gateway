#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name secgroup name] \n
[-r, --remote-ip] [-p, --port secgroup port] --
script to setup secgroups:\n
    -h  show this help text\n
    -l, --list secgroup list\n
    -n, --name secgroup name\n
    -r, --remote-ip allowable remote IPs (CIDR notation)\n
    -p, --port secgroup port\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            SECGROUP_NAME="$2"
            shift # past argument
            ;;
        -r|--remote-ip)
            REMOTE_IP="$2"
            shift # past argument
            ;;
        -p|--port)
            SECGROUP_PORT="$2"
            shift # past argument
            ;;
        -l|--list)
            openstack security group list
            exit
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$SECGROUP_NAME" ];
  then
      echo "Must supply a secgroup name:" 
      echo -e $usage
      exit 1
fi

if [ -z "$REMOTE_IP" ];
  then
      REMOTE_IP="0.0.0.0/0"
      echo "No remote IP so going with 0.0.0.0/0 (i.e., everyone)."
fi

if [ -z "$SECGROUP_PORT" ];
   then
      echo "Must supply a secgroup port:" 
      echo -e $usage
      exit 1
fi


openstack security group create --description "${SECGROUP_NAME} & icmp enabled" \
          ${SECGROUP_NAME}
openstack security group rule create --protocol tcp \
          --dst-port ${SECGROUP_PORT}:${SECGROUP_PORT} \
          --remote-ip ${REMOTE_IP} ${SECGROUP_NAME}
openstack security group rule create --protocol icmp ${SECGROUP_NAME}
openstack security group list
