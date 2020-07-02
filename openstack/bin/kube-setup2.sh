#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

export OS_TENANT_ID=$OS_PROJECT_ID

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

cd $HOME/jetstream_kubespray

ansible-playbook --become -i \
                 $HOME/jetstream_kubespray/inventory/$CLUSTER/hosts \
                 $HOME/jetstream_kubespray/cluster.yml

mkdir -p $HOME/.kube/

cp $HOME/jetstream_kubespray/inventory/$CLUSTER/artifacts/admin.conf \
    $HOME/.kube/config

sed -i 's/10\.0\.0\.[[:digit:]]\+/127.0.0.1/g' $HOME/.kube/config

FLOATINGIPOFMASTER=$(openstack server list | grep $CLUSTER | \
    grep -i master | awk 'BEGIN { FS = "|" } ; { print $5 }' | \
    awk '{print $NF}')

echo When cluster is ready, ssh tunnel into master node:
echo ssh ubuntu@${FLOATINGIPOFMASTER} -L 6443:localhost:6443
