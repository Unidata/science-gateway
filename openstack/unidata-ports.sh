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
nova secgroup-add-rule global-www tcp 443 443 0.0.0.0/0
secgroup.sh  -p 112 -n adde-112
secgroup.sh  -p 388 -n ldm-388
secgroup.sh  -p 8080 -n tomcat
nova secgroup-add-rule global-tomcat tcp 8443 8443 0.0.0.0/0
secgroup.sh  -p 5672 -n edex
nova secgroup-add-rule global-edex tcp 9581 9581 0.0.0.0/0
nova secgroup-add-rule global-edex tcp 9582 9582 0.0.0.0/0
nova secgroup-list
