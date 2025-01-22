# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=quay.io/jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV EDITOR=nano VISUAL=nano

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim nano curl zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Add environment files
ADD environment-fit25s-sounder.yml /tmp/
ADD environment-fit25s-era5.yml /tmp/

# Define and create conda environments
ARG ENVIRONMENTS="fit25s-sounder fit25s-era5"

RUN for env in $ENVIRONMENTS; do \
      mamba create --name $env --quiet --yes && \
      mamba install --quiet --yes \
        'conda-forge::nodejs' \
        'conda-forge::nb_conda_kernels' \
        'conda-forge::ipykernel' \
        'conda-forge::jupyterlab-git' \
        'conda-forge::ipywidgets' && \
      mamba env update --name $env -f /tmp/environment-$env.yml && \
      pip install --no-cache-dir nbgitpuller; \
    done && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions /home/$NB_USER

COPY Acknowledgements.ipynb /

ARG JUPYTER_SETTINGS_DIR=/opt/conda/share/jupyter/lab/settings/
COPY overrides.json $JUPYTER_SETTINGS_DIR

USER $NB_UID
