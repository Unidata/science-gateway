#!/bin/bash

function usage()
{
  echo -e "Syntax: $(basename "$0") [-h] [-o] [-n]"
  echo -e "script to  start OpenStack CL Docker container."
  echo -e "Arguments must be supplied with fully qualified paths."
  echo -e "\t-h show this help text"
  echo -e "\t-o, --openrc full path to directory with openrc.sh file obtained from Jetstream2"
  echo -e "\t-n, --name container name"
  exit 1
}

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -o|--openrc)
            OPENRC="$2"
            shift # past argument
            ;;
        -n|--name)
            NAME="$2"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$OPENRC" ];
   then
      echo "Must supply an openrc.sh file:"
      usage
      exit 1
fi

if [ -z "$NAME" ];
   then
      echo "Must supply a name for the new docker container:"
      usage
      exit 1
fi

docker run --name $NAME -it  \
       -v ${PWD}/bin:/home/openstack/bin/ \
       -v ${PWD}/.bashrc:/home/openstack/.bashrc \
       -v ${OPENRC}:/home/openstack/bin/openrc.sh \
       -v ${HOME}/security:/home/openstack/security \
       unidata/science-gateway /bin/bash
