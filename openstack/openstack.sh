#!/bin/bash

usage="$(basename "$0") [-h] [-s, --ssh .ssh dir] [-o, --openrc openrc.sh file] \n
-- script to  start openstack CL Docker container:\n
    -h  show this help text\n
    -s, --ssh .ssh directory containing your openstack Jetstream key\n
    -o, --openrc openrc.sh file obtained from Jetstream\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -s|--ssh)
            SSH_DIR="$2"
            shift # past argument
            ;;
        -o|--openrc)
            OPENRC="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z ${SSH_DIR+x} ];
  then
      echo "Must supply an .ssh directory:"
      echo -e $usage
      exit 1
fi

if [ -z ${OPENRC+x} ];
   then
      echo "Must supply an openrc.sh file:"
      echo -e $usage
      exit 1
fi

docker run -it  \
       -v ${SSH_DIR}:/home/openstack/.ssh/ \
       -v ${OPENRC}:/home/openstack/bin/openrc.sh \
       unidata/xsede-jetstream /bin/bash

