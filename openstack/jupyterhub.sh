#!/bin/bash -f
dir="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -d $dir/ssh ]; then
  mkdir $dir/ssh
  chmod 777 $dir/ssh # write access required for keygen
fi

function usage()
{
  echo -e "Syntax: $(basename "$0") [-h] [-n] [-p] [-o]"
  echo -e "script to fire up or access a Z2J JupyterHub."
  echo -e "\t-h show this help text"
  echo -e "\t-n, --name JupyterHub name"
  echo -e "\t-p, --ip JupyterHub IP"
  echo -e "\t-o, --openrc openrc.sh path"
  exit 1
}

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            JUPYTERHUB="$2"
            shift # past argument
            ;;
        -p|--ip)
            IP="$2"
            shift # past argument
            ;;
        -o|--openrc)
            OPENRC="$2"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$JUPYTERHUB" ];
  then
      echo "Must supply a JupyterHub name:"
      usage
      exit 1
fi

if [ -z "$IP" ];
  then
      echo "Must supply a JupyterHub IP:"
      usage
      exit 1
fi

if [ -z "$OPENRC" ];
  then
      echo "Must supply an openrc.sh path:"
      usage
      exit 1
fi

if [ ! -d $dir/jhubs ]; then
  mkdir $dir/jhubs
fi

./z2j.sh \
    -s ${dir}/ssh \
    -o $OPENRC \
    -k ${dir}/jhubs/${JUPYTERHUB}/kube \
    -n ${dir}/jhubs/${JUPYTERHUB}/novaclient \
    -t ${dir}/jhubs/${JUPYTERHUB}/terraform \
    -i ${dir}/jhubs/${JUPYTERHUB}/${JUPYTERHUB} \
    -p ${IP} \
    -m ${dir}/jhubs/${JUPYTERHUB}/helm \
    -c ${dir}/jhubs/${JUPYTERHUB}/secrets.yaml
