#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "${HOME}/jetstream_kubespray" || exit 1

cp /turnoff-unneeded-services.yml .
cp /uninstall-packages-cleanup.yml .

ansible-playbook --become -i "inventory/${CLUSTER}/hosts" turnoff-unneeded-services.yml -b -v --limit "${CLUSTER}*"

ansible-playbook --become -i "inventory/${CLUSTER}/hosts" uninstall-packages-cleanup.yml -b -v --limit "${CLUSTER}*"

echo
echo --------------------------------------------------------------------------------
echo You can now run kube-setup2.sh
