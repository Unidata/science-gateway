#!/bin/bash

usage="$(basename "$0") [-h] -- no argument script to create Unidata related ports; 22, 80, 112, 388, 443, 8080, 8443, and ports for EDEX .:\n
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

openstack security group create --description "global-ssh-22 & icmp enabled" \
          global-ssh-22
openstack security group rule create global-ssh-22 --protocol tcp --dst-port \
          22:22 --remote-ip 128.117.144.0/23
openstack security group rule create  global-ssh-22 --protocol tcp --dst-port \
          22:22 --remote-ip 128.117.164.80/28
openstack security group rule create  global-ssh-22 --protocol tcp --dst-port \
          22:22 --remote-ip 128.117.165.80/28
openstack security group rule create --protocol icmp global-ssh-22
secgroup.sh  -p 80 -n global-www
openstack security group rule create global-www --protocol tcp --dst-port \
          443:443 --remote-ip 0.0.0.0/0
secgroup.sh  -p 112 -n global-adde-112
secgroup.sh  -p 388 -n global-ldm-388
secgroup.sh  -p 8080 -n global-tomcat
openstack security group rule create global-tomcat --protocol tcp --dst-port \
          8443:8443 --remote-ip 0.0.0.0/0
secgroup.sh  -p 5672 -n global-edex
openstack security group rule create global-edex --protocol tcp --dst-port \
          9581:9581 --remote-ip 0.0.0.0/0
openstack security group rule create global-edex --protocol tcp --dst-port \
          9582:9582 --remote-ip 0.0.0.0/0
openstack security group rule create global-edex --protocol tcp --dst-port \
          5432:5432 --remote-ip 0.0.0.0/0
secgroup.sh  -p 111 -n local-nfs --remote-ip 10.0.0.0/24
openstack security group rule create local-nfs --protocol tcp --dst-port \
          1110:1110 --remote-ip 10.0.0.0/24
openstack security group rule create local-nfs --protocol tcp --dst-port \
          2049:2049 --remote-ip 10.0.0.0/24
openstack security group rule create local-nfs --protocol tcp --dst-port \
          4045:4045 --remote-ip 10.0.0.0/24
openstack security group list
secgroup.sh  -p 8000 -n global-jupyterhub
openstack security group rule create global-jupyterhub --protocol tcp --dst-port \
          8001:8001 --remote-ip 0.0.0.0/0
openstack security group rule create global-jupyterhub --protocol tcp --dst-port \
          8081:8081 --remote-ip 0.0.0.0/0
