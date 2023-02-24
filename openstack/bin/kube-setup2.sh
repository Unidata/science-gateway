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

echo When cluster is ready, ssh tunnel into master node:
echo ssh ubuntu@${IP} -L 6443:localhost:6443
echo Add your PKs to ~/.ssh/authorized_keys on ${IP}
echo
echo Add your email to \
     ~/jupyterhub-deploy-kubernetes-jetstream/setup_https/https_issuer.yml
echo kubectl patch storageclass cinder-csi -p \
     \'{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}\'
