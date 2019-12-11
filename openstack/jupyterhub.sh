#!/bin/bash -f
dir="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -d $dir/ssh ]; then
  mkdir $dir/ssh
  chmod 777 $dir/ssh # write access required for keygen
fi

usage="$(basename "$0") [-h]
[-n, --name JupyterHub Name]
-- script to fire up or access a Z2J JupyterHub. \n
    -h, --help show this help text\n
    -n, --name JupyterHub name\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            JUPYTERHUB="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$JUPYTERHUB" ];
  then
      echo "Must supply a JupyterHub name directory:"
      echo -e $usage
      exit 1
fi

./z2j.sh \
    -s ${dir}/ssh \
    -o ${dir}/bin/openrc.iu.sh \
    -k ${dir}/jhubs/${JUPYTERHUB}/kube \
    -n ${dir}/jhubs/${JUPYTERHUB}/novaclient \
    -t ${dir}/jhubs/${JUPYTERHUB}/terraform \
    -i ${dir}/jhubs/${JUPYTERHUB}/${JUPYTERHUB} \
    -m ${dir}/jhubs/${JUPYTERHUB}/helm \
    -c ${dir}/jhubs/${JUPYTERHUB}/secrets.yaml
