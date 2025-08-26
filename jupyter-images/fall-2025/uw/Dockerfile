# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=quay.io/jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV  EDITOR=nano VISUAL=nano
ENV MAMBA_ROOT_PREFIX=/opt/conda

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim nano curl zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY jupyter_server_proxy_config.py /etc/jupyter/jupyter_server_proxy_config.py
COPY setup-unidata-desktop.sh /usr/local/bin/before-notebook.d/
COPY IDV.desktop /usr/local/share/applications/
COPY cave.desktop /usr/local/share/applications/
RUN chmod +x /usr/local/share/applications/IDV.desktop && \
    chmod +x /usr/local/share/applications/cave.desktop && \
    cat /etc/jupyter/jupyter_server_proxy_config.py >> /etc/jupyter/jupyter_server_config.py

RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
  | tar -xvj -C /usr/local/bin bin/micromamba --strip-components=1

RUN mkdir -p /usr/local/share/icons

COPY unidata.svg /usr/local/share/icons

USER $NB_UID

ADD environment.yml /tmp
ADD environment-satpy.yml /tmp
ADD environment-geopandas.yml /tmp

ARG DEFAULT_ENV_NAME=uw-fall-2025
ARG SATPY_ENV_NAME=uw-satpy-fall-2025
ARG GEOPANDAS_ENV_NAME=uw-geopandas-fall-2025

RUN micromamba install -n base -y -c conda-forge \
      nb_conda_kernels jupyterlab-git ipywidgets jupyter-server-proxy && \
    micromamba update -n base mamba -y && \
    micromamba env create -n $DEFAULT_ENV_NAME -f /tmp/environment.yml && \
    micromamba env create -n $SATPY_ENV_NAME -f /tmp/environment-satpy.yml && \
    micromamba env create -n $GEOPANDAS_ENV_NAME -f /tmp/environment-geopandas.yml && \
    pip install --no-cache-dir nbgitpuller && \
    micromamba clean --all -f -y && \
    jupyter lab clean -y && \
    rm -rf /home/$NB_USER/.cache/yarn /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN micromamba install -n $DEFAULT_ENV_NAME -c conda-forge pyproj argopy sqlite

COPY update_material.ipynb Acknowledgements.ipynb default_kernel.py  /

ARG JUPYTER_SETTINGS_DIR=/opt/conda/share/jupyter/lab/settings/
COPY overrides.json $JUPYTER_SETTINGS_DIR

USER $NB_UID
