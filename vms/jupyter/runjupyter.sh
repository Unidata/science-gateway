#!/bin/bash

adduser --disabled-password --gecos "" jupyter

# Reset directories to baseline jupyter user. After user logs in for the first
# time, they will reassert ownership for their directories (see
# jupyterhub_config.py). This action is to prevent confusing (although
# inconsequential) ownership in the /notebooks directory due to UID mismatches
# from one container instantiating to the next.
for i in /notebooks/*
do
    chown jupyter:docker $i
    # Restrict directories to owner only
    chmod 711 $i
done

jupyterhub -f /etc/jupyterhub/jupyterhub_config.py >> /var/log/jupyterhub.log 2>&1
