# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    vim \
    emacs \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

ADD environment.yml /tmp

RUN conda install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    conda env update --name rg-fall-2022 -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY .condarc /

USER ${NB_UID}

WORKDIR "${HOME}"
