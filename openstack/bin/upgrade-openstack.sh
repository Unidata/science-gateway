#!/bin/bash

# https://docs.jetstream-cloud.org/ui/cli/clients/
# "Following future OpenStack updates, all installed pip modules can be updated with this command:"

pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
