#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

usage="$(basename "$0") [-h] [-n, --name cluster name] --
script to create k8 clusters.:\n
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

sed -i "s/MODIFY_THIS_TO_UNIQUE_VALUE/"$CLUSTER"_kube_network/g" \
    $HOME/jetstream_kubespray/inventory/zonca/cluster.tf

sed -i 's/# kubectl_localhost: false/kubectl_localhost: true/g' \
   $HOME/jetstream_kubespray/inventory/zonca/group_vars/k8s-cluster/k8s-cluster.yml


cd $HOME/jetstream_kubespray/
cp -LRp inventory/zonca inventory/$CLUSTER
cd inventory/$CLUSTER

bash terraform_init.sh
bash terraform_apply.sh

echo Give a chance for dpkg to run on newly minted VMs for 5 minutes

sleep 300

echo Now reboot VMs

openstack server list | grep $CLUSTER | awk '{print $2}' \
    | xargs -n1 openstack server reboot

echo Give a chance for VMs to reboot for 5 minutes

sleep 300

openstack server list

echo watch -n 15 \
     ansible -i $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts -m ping all
echo Once VMs are ready:
echo kube-setup2.sh -n $CLUSTER
