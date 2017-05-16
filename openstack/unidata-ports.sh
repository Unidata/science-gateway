#!/bin/bash

usage="$(basename "$0") [-h] -- no argument script to create Unidata related ports; 22, 80, 112, 388, 443, 8080, 8443 .:\n
    -h  show this help text\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

# secgroup.sh automatically prepends "global-" to the secgroup name
secgroup.sh  -p 22 -n ssh-22
secgroup.sh  -p 80 -n www
openstack security group rule create global-www --protocol tcp --dst-port 443:443 --remote-ip 0.0.0.0/0
secgroup.sh  -p 112 -n adde-112
secgroup.sh  -p 388 -n ldm-388
secgroup.sh  -p 8080 -n tomcat
openstack security group rule create global-tomcat --protocol tcp --dst-port 8443:8443 --remote-ip 0.0.0.0/0
secgroup.sh  -p 5672 -n edex
openstack security group rule create global-tomcat --protocol tcp --dst-port 9581:9581 --remote-ip 0.0.0.0/0
openstack security group rule create global-tomcat --protocol tcp --dst-port 9582:9582 --remote-ip 0.0.0.0/0
openstack security group list
