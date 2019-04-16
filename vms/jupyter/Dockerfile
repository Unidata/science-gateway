# Heavily borrowed from docker-stacks/scipy-notebook/

ARG BASE_CONTAINER=jupyter/minimal-notebook
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
    cd /tmp && \
    git clone https://github.com/Unidata/unidata-python-workshop && \
    cd unidata-python-workshop && \
    conda env update --name unidata-python-workshop -f environment.yml && \
    cd && \
    rm -rf /tmp/unidata-python-workshop && \
    cd /tmp && \
    git clone https://github.com/Unidata/notebook-gallery && \
    cd notebook-gallery && \
    conda env update --name notebook-gallery -f environment.yml && \
    cd && \
    rm -rf /tmp/notebook-gallery && \
    cd /tmp && \
    git clone https://github.com/Unidata/python-awips && \
    cd python-awips && \
    conda env update --name python-awips -f environment.yml && \
    cd && \
    rm -rf /tmp/python-awips && \
    cd /tmp && \
    git clone -b master https://github.com/Unidata/online-python-training && \
    cd online-python-training && \
    conda env update --name online-python-training -f environment.yml && \
    cd && \
    rm -rf /tmp/online-python-training && \
    conda clean -tipsy && \
    pip install --upgrade pip && \
    pip install nbgitpuller && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^0.38.1 && \
    jupyter labextension install jupyterlab_bokeh@0.6.3 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY README_FIRST.ipynb /
    
USER $NB_UID
