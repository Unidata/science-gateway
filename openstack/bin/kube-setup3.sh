#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

EMAIL="${1:-}"

replace_email() {
    local email="$1"
    local directory="${HOME}/jupyterhub-deploy-kubernetes-jetstream/setup_https"

    if [ -n "$email" ]; then
        grep -Rl 'YOUREMAIL' "$directory" | xargs sed -i "s/YOUREMAIL/$email/g"
    fi
}

cd "${HOME}/jetstream_kubespray" || exit 1

cp "${HOME}/.ssh/unidata-tasks.yml" .

ansible-playbook --become -i "inventory/${CLUSTER}/hosts" unidata-tasks.yml -b -v --limit "${CLUSTER}-1"

replace_email "$EMAIL"
