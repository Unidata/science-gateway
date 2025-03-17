# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=quay.io/jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=nps25s EDITOR=nano VISUAL=nano

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim nano curl zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ADD environment.yml /tmp

RUN mamba create --name $DEFAULT_ENV_NAME --quiet --yes && \
    mamba install --quiet --yes \
      'conda-forge::nodejs' \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
      'conda-forge::jupyter-server-proxy' \
      'conda-forge::ipywidgets' && \
    mamba env update --name $DEFAULT_ENV_NAME -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    mamba clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY update_material.ipynb Acknowledgements.ipynb \
     default_kernel.py .condarc /

ARG JUPYTER_SETTINGS_DIR=/opt/conda/share/jupyter/lab/settings/
COPY overrides.json $JUPYTER_SETTINGS_DIR

USER $NB_UID
