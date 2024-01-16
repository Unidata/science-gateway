# Heavily borrowed from docker-stacks
# https://github.com/jupyter/docker-stacks/blob/main/docker-stacks-foundation/Dockerfile

ARG BASE_CONTAINER=nvcr.io/nvidia/tensorflow:23.12-tf2-py3
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    bzip2 ca-certificates locales sudo wget software-properties-common \
    libgeos-dev libproj-dev proj-data proj-bin libnetcdf-dev netcdf-bin && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN python3 -m pip install --no-cache-dir \
    bokeh \
    h5py \
    ipywidgets \
    jupyter-server-proxy \
    jupyter_server \
    jupyter_server_terminals==0.4.4 \
    jupyterhub==3.0.0 \
    jupyterlab \
    jupyterlab_widgets \
    keras \
    matplotlib \
    nbgitpuller \
    netcdf4 \
    notebook \
    numpy \
    optuna \
    pandas \
    scikit-learn \
    scipy \
    shapely \
    torch \
    torchvision \
    visualkeras \
    xarray \
    --upgrade

RUN python3 -m pip install --no-cache-dir \
    OWSLib>=0.24.1 \
    cartopy \
    fiona>=1.0 \
    matplotlib>=3.5 \
    pillow>=6.1.0 \
    pykdtree>=1.2.2 \
    pyproj>=3.1.0 \
    pyshp>=2.3 \
    pytest-mpl>=0.11 \
    pytest>=5.1.2 \
    scipy>=1.6.3 \
    shapely>=1.7.1 \
    --upgrade

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

ENV HOME="/home/${NB_USER}"

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" && \
    chmod g+w /etc/passwd && fix-permissions "${HOME}"

COPY Acknowledgements.ipynb /

USER ${NB_UID}

WORKDIR "${HOME}"
