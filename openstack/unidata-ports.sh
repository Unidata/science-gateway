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

secgroup.sh  -p 22 -n ssh-22
secgroup.sh  -p 80 -n http-80
secgroup.sh  -p 112 -n adde-112
secgroup.sh  -p 388 -n ldm-388
secgroup.sh  -p 443 -n ssl-443
secgroup.sh  -p 8080 -n tomcat-http-8080
secgroup.sh  -p 8443 -n tomcat-ssl-8443
