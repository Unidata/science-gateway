# Heavily borrowed from docker-stacks/scipy-notebook/
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ffmpeg vim curl

ADD environment /environment
ADD README.md /README.md
ADD README_USER.ipynb /README_USER.ipynb

########
# Compile summa
# https://summa.readthedocs.io/en/latest/installation/SUMMA_installation/
########

# Install necessary libraries, headers, and compilation packages
RUN apt-get install -y --no-install-recommends \
    gfortran libatlas3-base liblapack3 liblapacke-dev libnetcdff-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build summa 
RUN git clone https://github.com/CH-Earth/summa.git /summa && \
    cd /summa/build && \
    git checkout master && \
    export F_MASTER=/summa && \
    export FC=gfortran && \
    export FC_EXE=gfortran && \
    export INCLUDES='-I/usr/include' && \
    export LIBRARIES='-L/usr/lib/x86_64-linux-gnu -lnetcdff -lblas -L/usr/lib/x86_64-linux-gnu/lapack -llapack' && \
    make && \
    cp /summa/bin/summa.exe /usr/local/bin && \
    unset F_MASTER FC FC_EXE INCLUDES LIBRARIES

RUN mamba install --yes 'conda-forge::nb_conda_kernels' && \
    pip install --upgrade jupyterlab-git jupyter_sql && \
    mamba env update --name saswata2022 -f /environment/data-spec.yml && \
    mamba env update --name saswata2022 -f /environment/io.yml && \
    mamba env update --name saswata2022 -f /environment/analyze.yml && \
    mamba env update --name saswata2022 -f /environment/modelling.yml && \
    mamba env update --name saswata2022 -f /environment/data-viz.yml && \
    mamba clean --all -f -y && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID
