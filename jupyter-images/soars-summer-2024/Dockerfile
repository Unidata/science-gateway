# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    bzip2 wget curl  && \
    apt-get install -y python3.10 python3.10-distutils && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    ln -sfn /usr/bin/python3.10 /usr/bin/python3 && \
    ln -sfn /usr/bin/python3 /usr/bin/python && \
    ln -sfn /usr/bin/pip3 /usr/bin/pip && \
    pip install --no-cache-dir jupyterhub==3.0.0 && \
    pip install --no-cache-dir --upgrade jupyterlab notebook jupyter_server jupyterlab-git && \
    python3 -m pip install  jupyterlab-github ipydrawio[all] jupyter_ai nbdime && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    fix-permissions "${HOME}" && \
    locale-gen

USER $NB_UID

COPY Acknowledgements.ipynb /

USER $NB_UID
