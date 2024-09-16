# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=uw-fall-2024

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl zip unzip nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ADD environment.yml /tmp
ADD environment-satpy.yml /tmp

RUN mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
      'conda-forge::ipywidgets' && \
    mamba update mamba -y && \
    mamba env update --name $DEFAULT_ENV_NAME -f /tmp/environment.yml && \
    mamba env update --name uw-satpy-fall-2024 -f /tmp/environment-satpy.yml && \
    pip install --no-cache-dir nbgitpuller && \
    mamba clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda install -n uw-fall-2024 -c conda-forge --force-reinstall pyproj \
    geopandas argopy sqlite

COPY Acknowledgements.ipynb /
COPY .gitconfig /

USER $NB_UID
