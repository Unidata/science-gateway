# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook:ubuntu-20.04
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    vim \
    emacs \
    curl && \
    wget \
    https://github.com/NCAR/lrose-core/releases/download/lrose-core-20220222/lrose-core-20220222.ubuntu_20.04.amd64.deb -P /tmp && \
    apt-get install -y /tmp/lrose-core-20220222.ubuntu_20.04.amd64.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

ADD environment.yml /tmp

RUN conda update conda && \
    conda install --quiet --yes \
    'conda-forge::nb_conda_kernels' && \
    conda env update --name lrose-ams-2023 -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY update_workshop_material.ipynb /
COPY Acknowledgements.ipynb /
COPY .condarc /
COPY .bashrc /
COPY .profile /

USER ${NB_UID}

WORKDIR "${HOME}"
