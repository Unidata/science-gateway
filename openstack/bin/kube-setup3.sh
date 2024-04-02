#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

replace_email() {
    local email="letsencrypt@unidata.ucar.edu"
    local directory="${HOME}/jupyterhub-deploy-kubernetes-jetstream/setup_https"
    grep -Rl 'YOUREMAIL' "$directory" | xargs sed -i "s/YOUREMAIL/$email/g"
}

cd "${HOME}/jetstream_kubespray" || exit 1

cp "${HOME}/.ssh/unidata-tasks.yml" .

ansible-playbook --become -i "inventory/${CLUSTER}/hosts" unidata-tasks.yml -b -v --limit "${CLUSTER}-1"

replace_email
