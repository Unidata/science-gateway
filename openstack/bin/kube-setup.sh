#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

sed -i "s/kubespray-network/"$CLUSTER"_kube_network/g" \
    $HOME/jetstream_kubespray/inventory/kubejetstream/cluster.tfvars

sed -i "s/kubejetstream/"$CLUSTER"/g" \
    $HOME/jetstream_kubespray/inventory/kubejetstream/cluster.tfvars

sed -i "s/zonca-api-key.pub/id_rsa.pub/g" \
    $HOME/jetstream_kubespray/inventory/kubejetstream/cluster.tfvars

sed -i 's/# kubectl_localhost: false/kubectl_localhost: true/g' \
   $HOME/jetstream_kubespray/inventory/kubejetstream/group_vars/k8s-cluster/k8s-cluster.yml

cd $HOME/jetstream_kubespray/
mkdir -p inventory/$CLUSTER && cp -LRp inventory/kubejetstream/* inventory/$CLUSTER
cd inventory/$CLUSTER

bash terraform_init.sh
bash terraform_apply.sh

openstack server list

echo watch -n 15 \
     ansible -i $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts -m ping all
echo Once VMs are ready:
echo kube-setup2.sh
