#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

sed -i "s/MODIFY_THIS_TO_UNIQUE_VALUE/"$CLUSTER"_kube_network/g" \
    $HOME/jetstream_kubespray/inventory/zonca/cluster.tf

sed -i 's/# kubectl_localhost: false/kubectl_localhost: true/g' \
   $HOME/jetstream_kubespray/inventory/zonca/group_vars/k8s-cluster/k8s-cluster.yml


cd $HOME/jetstream_kubespray/
mkdir -p inventory/$CLUSTER && cp -LRp inventory/zonca/* inventory/$CLUSTER
cd inventory/$CLUSTER

bash terraform_init.sh
bash terraform_apply.sh

openstack server list

echo watch -n 15 \
     ansible -i $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts -m ping all
echo Once VMs are ready:
echo kube-setup2.sh
