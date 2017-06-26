#!/bin/bash

jupyterhub -f /etc/jupyterhub/jupyterhub_config.py >> /var/log/jupyterhub.log 2>&1
