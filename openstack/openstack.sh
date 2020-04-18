#!/bin/bash

usage="$(basename "$0") [-h] [-s, --ssh ssh directory path] [-o, --openrc openrc.sh file path] \n
-- script to  start OpenStack CL Docker container. \n Arguments must be supplied with fully qualified paths.\n
    -h  show this help text\n
    -s, --ssh full path to ssh directory containing your OpenStack Jetstream key\n
    -o, --openrc full path to directory with openrc.sh file obtained from Jetstream (bin)\n"

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

if [ -z "$SSH_DIR" ];
  then
      echo "Must supply an .ssh directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$OPENRC" ];
   then
      echo "Must supply an openrc.sh file:"
      echo -e $usage
      exit 1
fi

docker run -it  \
       -v ${SSH_DIR}:/home/openstack/.ssh/ \
       -v ${OPENRC}:/home/openstack/bin/openrc.sh \
       unidata/science-gateway /bin/bash

