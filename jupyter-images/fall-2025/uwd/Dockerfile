ARG BASE_CONTAINER=pangeo/base-notebook:2023.07.02
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl wget csh git \
    graphviz build-essential libnetcdf-dev netcdf-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN . /srv/conda/etc/profile.d/conda.sh && conda activate notebook && \
    mamba install 'pip' 'nodejs>=18.0.0' && \
    pip install 'cloudpickle==3.1.2' && \
    pip install 'distributed==2025.11.0' && \
    pip install 'toolz==0.12.0' && \
    pip install 'cytoolz==1.1.0'  && \
    pip install 'lz4==4.3.3'  && \
    pip install 'tornado==6.5.2' && \
    pip install 'dask==2025.11.0'  && \
    pip install 'msgpack==1.0.8'  && \
    pip install 'pandas==2.2.2'  && \
    pip install 'xarray'  && \
    pip install 'ipywidgets'  && \
    pip install 'graphviz'  && \
    pip install 'matplotlib'  && \
    pip install 'netcdf4'  && \
    pip install 'h5netcdf'  && \
    pip install 'siphon'  && \
    pip install 'pydap'  && \
    pip install 'scipy'  && \
    pip install 'nodejs'  && \
    pip install 'nbgitpuller'  && \
    pip install 'nbdime'  && \
    pip install 'numpy==2.1.0' && \
    pip install 'dask-kubernetes' && \
    pip install 'dask-gateway==2025.4.0'

RUN . /srv/conda/etc/profile.d/conda.sh && conda activate notebook && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp"

COPY ERA5_data_fetcher.ipynb Dask.ipynb wrf.ipynb Acknowledgements.ipynb /

USER $NB_UID
