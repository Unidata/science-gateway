# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

COPY ./environment.yml /tmp/environment.yml

RUN conda install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    conda env update --name vt-spring-2023 -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    conda clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY additional_kernels.ipynb /
COPY .condarc /
COPY Acknowledgements.ipynb /

USER $NB_UID
