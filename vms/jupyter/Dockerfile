# Heavily borrowed from docker-stacks/scipy-notebook/

ARG BASE_CONTAINER=jupyter/minimal-notebook:2ce7c06a61a1
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-python@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

RUN conda install --quiet --yes \
    'ipywidgets=7.2*' \
    'conda-forge::nb_conda_kernels'  && \
    wget https://raw.githubusercontent.com/Unidata/python-workshop/master/environment.yml && \
    conda env update --name unidata-python-workshop -f environment.yml && \
    rm environment.yml && \
    wget https://raw.githubusercontent.com/Unidata/notebook-gallery/master/environment.yml && \
    conda env update --name notebook-gallery -f environment.yml && \
    rm environment.yml && \
    wget https://raw.githubusercontent.com/Unidata/online-python-training/master/environment.yml && \
    conda env update --name online-python-training -f environment.yml && \
    rm environment.yml && \
    conda clean -tipsy && \
    pip install --no-cache-dir nbgitpuller && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^1.0.1 --no-build && \
    jupyter labextension install jupyterlab_bokeh@1.0.0 --no-build && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY README_FIRST.ipynb /
    
USER $NB_UID
