# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=mines23f

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Pull environment file from the course's repo
RUN curl -o /tmp/environment.yml https://raw.githubusercontent.com/mines-erds/557-2023/main/557_env.yaml

RUN mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
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

COPY update_material.ipynb Acknowledgements.ipynb default-kernel.py /

USER $NB_UID
