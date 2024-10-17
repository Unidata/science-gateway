# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

# Due to a linking issue with glibc, I'm basing this image off a previous
# semester's image

FROM unidata/mvu24s:2024Mar12_145946_8a22

ENV DEFAULT_ENV_NAME=mvu24f EDITOR=nano VISUAL=nano

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim nano curl zip unzip wget \
      gcc cpp gfortran g++ openmpi-bin libopenmpi-dev git csh perl file \
      make m4 ca-certificates libgl1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

ADD environment.yml /tmp

# Rename the previous environment before updating it
RUN mamba rename -n mvu24s $DEFAULT_ENV_NAME && \
    mamba install --quiet --yes \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
      'conda-forge::ipywidgets' && \
    mamba env update --name $DEFAULT_ENV_NAME -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    mamba clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY additional_kernels.ipynb update_material.ipynb Acknowledgements.ipynb \
    default_kernel.py .condarc /

ARG JUPYTER_SETTINGS_DIR=/opt/conda/share/jupyter/lab/settings/
COPY overrides.json $JUPYTER_SETTINGS_DIR

RUN chown -R ${NB_UID}:${NB_GID} /Build_WRF/WRF && \
    ldconfig /Build_WRF/LIBRARIES/netcdf/lib

USER $NB_UID
