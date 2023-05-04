# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./environment.yml /environment.yml
COPY ./Acknowledgements.ipynb /Acknowledgements.ipynb 

RUN chmod a+r /environment.yml /Acknowledgements.ipynb

# Clone the base scipy-notebook environment and then add any explicitly desired
# packages through our /environment.yml file added to the image above
# Using mamba instead of conda as mamba seems better at resolving dependencies
RUN mamba install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    pip install --upgrade jupyterlab-git jupyterlab_sql && \
    mamba create --name sau-s23 --clone base && \
    mamba env update --name sau-s23 -f /environment.yml && \
    mamba clean --all -f -y && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID

