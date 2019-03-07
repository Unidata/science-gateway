#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

usage="$(basename "$0") [-h] [-n, --name cluster name] --
script to create k8 clusters, part 2.:\n
    -h  show this help text\n
    -n, --name cluster name.\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            NAME="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$NAME" ];
  then
      echo "Must supply a cluster name:"
      echo -e $usage
      exit 1
fi

export CLUSTER=$NAME

export OS_TENANT_ID=$OS_PROJECT_ID

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

ansible-playbook --become -i \
                 $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts \
                 $HOME/jetstream_kubespray/cluster.yml

mkdir -p $HOME/.kube/

cp $HOME/jetstream_kubespray/inventory/$CLUSTER/artifacts/admin.conf \
    $HOME/.kube/config

sed -i 's/10\.0\.0\.[[:digit:]]\+/127.0.0.1/g' $HOME/.kube/config

echo When cluster is ready, ssh tunnel into master node:
echo ssh ubuntu@FLOATINGIPOFMASTER -L 6443:localhost:6443
