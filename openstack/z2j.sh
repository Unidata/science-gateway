#!/bin/bash

function usage()
{
  echo -e "Syntax: $(basename "$0") [-h] [-s] [-o] [-k] [-n] [-t] [-i] [-p] [-m] [-c]"
  echo -e "script to  start Z2J Kube Client Docker container."
  echo -e "Arguments must be supplied with fully qualified paths."
  echo -e "\t-h, show this help text"
  echo -e "\t-s, --ssh full path to ssh directory containing your OpenStack Jetstream2 key"
  echo -e "\t-o, --openrc full path to directory with openrc.sh file obtained from Jetstream2"
  echo -e "\t-k, --kube full path to .kube directory"
  echo -e "\t-n, --novaclient full path to .kube directory"
  echo -e "\t-t, --terraform full path to .terraform directory"
  echo -e "\t-i, --inventory full path to kubespray inventory directory"
  echo -e "\t-p, --ip cluster ip"
  echo -e "\t-m, --helm full path to helm directory"
  echo -e "\t-c, --secrets.yaml full path"
  exit 1
}

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
        -k|--kube)
            KUBE="$2"
            shift # past argument
            ;;
        -n|--novaclient)
            NOVACLIENT="$2"
            shift # past argument
            ;;
        -t|--terraform)
            TERRAFORM="$2"
            shift # past argument
            ;;
        -i|--inventory)
            KUBESPRAY_INVENTORY="$2"
            shift # past argument
            ;;
        -p|--ip)
            IP="$2"
            shift # past argument
            ;;
        -m|--helm)
            HELM="$2"
            shift # past argument
            ;;
        -c|--secrets)
            SECRETS="$2"
            shift # past argument
            ;;
        -h|--help)
            usage
            exit
            ;;
    esac
    shift # past argument or value
done


if [ -z "$SSH_DIR" ];
  then
      echo "Must supply an .ssh directory:"
      usage
      exit 1
fi

if [ -z "$OPENRC" ];
   then
      echo "Must supply an openrc.sh file:"
      usage
      exit 1
fi

if [ -z "$KUBE" ];
   then
      echo "Must supply a .kube directory:"
      usage
      exit 1
fi

if [ -z "$NOVACLIENT" ];
   then
      echo "Must supply a .novaclient directory:"
      usage
      exit 1
fi

if [ -z "$TERRAFORM" ];
   then
      echo "Must supply a .terraform.d directory:"
      usage
      exit 1
fi

if [ -z "$KUBESPRAY_INVENTORY" ];
   then
      echo "Must supply a kubespray inventory directory:"
      usage
      exit 1
fi

if [ -z "$IP" ];
   then
      echo "Must supply a cluster IP:"
      usage
      exit 1
fi

if [ -z "$HELM" ];
   then
      echo "Must supply a helm directory:"
      usage
      exit 1
fi

if [ -z "$SECRETS" ];
   then
      echo "Must supply a secrets.yaml file:"
      usage
      exit 1
fi

mkdir -p $KUBE
mkdir -p $NOVACLIENT
mkdir -p $TERRAFORM
mkdir -p $KUBESPRAY_INVENTORY
INVENTORY="$(basename "$KUBESPRAY_INVENTORY")"
mkdir -p $HELM
touch ${SECRETS}

docker run -it  --name  ${INVENTORY} \
       -v ${SSH_DIR}:/home/openstack/.ssh/ \
       -v ${OPENRC}:/home/openstack/bin/openrc.sh \
       -v ${KUBE}:/home/openstack/.kube/ \
       -v ${NOVACLIENT}:/home/openstack/.novaclient/ \
       -v ${TERRAFORM}:/home/openstack/.terraform.d/ \
       -v ${KUBESPRAY_INVENTORY}:/home/openstack/jetstream_kubespray/inventory/${INVENTORY} \
       -v ${HELM}:/home/openstack/.helm \
       -v ${SECRETS}:/home/openstack/jupyterhub-deploy-kubernetes-jetstream/secrets.yaml \
       -e CLUSTER=${INVENTORY} \
       -e IP=${IP} \
       unidata/science-gateway /bin/bash
