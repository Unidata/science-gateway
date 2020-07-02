#!/bin/bash

usage="$(basename "$0") [-h]
[-s, --ssh ssh directory path]
[-o, --openrc openrc.sh file path]
[-k, --kube .kube path]
[-n, --novaclient .novaclient path]
[-t, --terraform .terraform path]
[-i, --inventory kubespray inventory path]
[-m, --helm .helm path]
-- script to  start Z2J Kube Client Docker container. \n
Arguments must be supplied with fully qualified paths.\n
    -h  show this help text\n
    -s, --ssh full path to ssh directory containing your OpenStack Jetstream key\n
    -o, --openrc full path to directory with openrc.sh file obtained from Jetstream (bin)\n
    -k, --kube full path to .kube directory (or one will be created for you)\n
    -n, --novaclient full path to .novaclient directory (or one will be created for you)\n
    -t, --terraform full path to .terraform directory (or one will be created for you)\n
    -i, --inventory full path to kubespray inventory directory (or one will be created for you)\n
    -m, --helm full path to .helm directory (or one will be created for you)\n
    -c, --secrets.yaml full path\n"

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
        -m|--helm)
            HELM="$2"
            shift # past argument
            ;;
        -c|--secrets)
            SECRETS="$2"
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

if [ -z "$KUBE" ];
   then
      echo "Must supply a .kube directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$NOVACLIENT" ];
   then
      echo "Must supply a .novaclient directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$TERRAFORM" ];
   then
      echo "Must supply a .terraform.d directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$KUBESPRAY_INVENTORY" ];
   then
      echo "Must supply a kubespray inventory directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$HELM" ];
   then
      echo "Must supply a helm directory:"
      echo -e $usage
      exit 1
fi

if [ -z "$SECRETS" ];
   then
      echo "Must supply a secrets.yaml file:"
      echo -e $usage
      exit 1
fi

mkdir -p $KUBE
mkdir -p $NOVACLIENT
mkdir -p $TERRAFORM
mkdir -p $KUBESPRAY_INVENTORY
INVENTORY="$(basename "$KUBESPRAY_INVENTORY")"
mkdir -p $HELM
touch ${SECRETS}

docker run -it  \
       -v ${SSH_DIR}:/home/openstack/.ssh/ \
       -v ${OPENRC}:/home/openstack/bin/openrc.sh \
       -v ${KUBE}:/home/openstack/.kube/ \
       -v ${NOVACLIENT}:/home/openstack/.novaclient/ \
       -v ${TERRAFORM}:/home/openstack/.terraform.d/ \
       -v ${KUBESPRAY_INVENTORY}:/home/openstack/jetstream_kubespray/inventory/${INVENTORY} \
       -v ${HELM}:/home/openstack/.helm \
       -v ${SECRETS}:/home/openstack/jupyterhub-deploy-kubernetes-jetstream/secrets.yaml \
       -e CLUSTER=${INVENTORY} \
       unidata/science-gateway /bin/bash
