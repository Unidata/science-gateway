#!/bin/bash
mkdir -p ~/config/
cp jupyterhub_config.py ~/config/

mkdir -p ~/nginx/
cp nginx.conf ~/nginx/

mkdir -p ~/logs/jupyter/

mkdir -p ~/logs/nginx/

mkdir -p ~/config/ssl/

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=jetstream.unidata.ucar.edu" \
  -keyout ~/config/ssl/ssl.key \
  -out ~/config/ssl/ssl.crt
