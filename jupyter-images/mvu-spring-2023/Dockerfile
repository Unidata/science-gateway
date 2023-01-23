ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

ENV DATA /data/

# ffmpeg for matplotlib anim & dvipng for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-client wget && \
    mkdir ${DATA} && \
    wget -O - https://www.radiativetransfer.org/misc/download/unstable/arts-cat-data-snapshot-arts-2.5.8.tar.gz | tar -xzf - -C ${DATA} && \
    rm -rf /var/lib/apt/lists/*

ADD environment.yml /tmp

RUN conda install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    pip install --upgrade jupyterlab-git nbgitpuller  && \
    conda env update --name mvu-spring-2023 -f /tmp/environment.yml && \
    rm /tmp/environment.yml && \
    conda clean --all -f -y && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    fix-permissions "${DATA}"

COPY Acknowledgements.ipynb /
COPY .condarc /
COPY .bashrc /
COPY .profile /

USER $NB_UID
