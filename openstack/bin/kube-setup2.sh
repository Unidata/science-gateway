#!/bin/bash

# scriptified https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html

export OS_TENANT_ID=$OS_PROJECT_ID

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

cd $HOME/jetstream_kubespray

bash k8s_install.sh

mkdir -p $HOME/.kube/

cp $HOME/jetstream_kubespray/inventory/$CLUSTER/artifacts/admin.conf \
    $HOME/.kube/config

sed -i 's/10\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+/127.0.0.1/g' $HOME/.kube/config

echo
echo --------------------------------------------------------------------------------
echo "When ready, call kube-setup3.sh <your-optional-email>"
