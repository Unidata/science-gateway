# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=unc-spring-2024

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
      'conda-forge::ipywidgets' && \
    wget https://raw.githubusercontent.com/Unidata/metpy-ams-2024/main/environment.yml && \
    mamba env update --name $DEFAULT_ENV_NAME -f environment.yml && \
    rm environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    mamba clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY update_material.ipynb Acknowledgements.ipynb default_kernel.py /

USER $NB_UID
