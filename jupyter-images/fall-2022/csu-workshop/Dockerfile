# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/minimal-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN conda install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    wget https://raw.githubusercontent.com/Unidata/metpy-workshop/main/environment.yml && \
    conda env update --name pyaos-ams-2022 -f environment.yml && \
    rm environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    conda clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY update_workshop_material.ipynb /
COPY additional_kernels.ipynb /
COPY .condarc /
COPY PythonforAS_EDA_CourseMaterials.zip /
COPY Day2_PythonforAS_troubleshooting_CourseMaterials.zip /

USER $NB_UID
