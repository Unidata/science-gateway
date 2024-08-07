# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile

# https://discourse.jupyter.org/t/keyerror-missing-required-environment-jupyterhub-service-url/19096
ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=fit23f

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ADD environment.yml /tmp

RUN mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
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
