# Heavily borrowed from docker-stacks/minimal-notebook/
# https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile

ARG BASE_CONTAINER=quay.io/jupyter/minimal-notebook
FROM $BASE_CONTAINER

ENV DEFAULT_ENV_NAME=unidata-standard EDITOR=nano VISUAL=nano \
    # Jupyter with VNC parameters \
    JVNC_URL=https://raw.githubusercontent.com/ana-v-espinoza/jupyter-with-vnc/refs/heads/main \
    DISPLAY=:1 \
    NOVNC_DIR=/novnc \
    DESKTOP_ENVIRONMENT=xfce

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends vim nano curl zip unzip \
      # For app streaming \
      # Dummy X server; vnc server & client \
      x11vnc xvfb xinit novnc xarclock \
      # Some programs for a minimal xfce4 desktop \
      thunar xfdesktop4 xfwm4 xfce4-panel xfce4-session \
      xfce4-appfinder mousepad xfce4-terminal dbus-x11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Used to run the novnc websockets proxy server:
    # https://github.com/novnc/noVNC/?tab=readme-ov-file#quick-start
    git clone https://github.com/novnc/novnc --depth=1 ${NOVNC_DIR} && \
    chown -R 1000:100 ${NOVNC_DIR}

COPY IDV.desktop /usr/local/share/applications/
COPY copy-idv-desktop-icon.sh /usr/local/bin/before-notebook.d/

RUN curl -SL \
  https://ramadda.scigw.unidata.ucar.edu/repository/entry/get/IDV_6.3.tar.bz2?entryid=c3ffcffc-c50c-4e19-95e1-9a913e486182 \
    -o /IDV.tar.bz2 && tar xvfj /IDV.tar.bz2 -C / && \
    chmod +x /usr/local/share/applications/IDV.desktop

USER $NB_UID

ADD environment.yml /tmp

RUN mamba create --name $DEFAULT_ENV_NAME --quiet --yes && \
    mamba install --quiet --yes \
      'conda-forge::nodejs' \
      'conda-forge::nb_conda_kernels' \
      'conda-forge::jupyterlab-git' \
      'conda-forge::ipywidgets' \
      'conda-forge::jupyter-server-proxy' && \
    mamba env update --name $DEFAULT_ENV_NAME -f /tmp/environment.yml && \
    pip install --no-cache-dir nbgitpuller && \
    mamba clean --all -f -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY additional_kernels.ipynb Acknowledgements.ipynb \
    default_kernel.py .condarc /

ARG JUPYTER_SETTINGS_DIR=/opt/conda/share/jupyter/lab/settings/
COPY overrides.json $JUPYTER_SETTINGS_DIR
# Jupyter with VNC auxiliary files

USER root
RUN wget ${JVNC_URL}/jupyter_server_proxy_config.py \
       -O /etc/jupyter/jupyter_server_proxy_config.py && \
    cat /etc/jupyter/jupyter_server_proxy_config.py >> /etc/jupyter/jupyter_server_config.py && \
    wget ${JVNC_URL}/start_virtual_desktop.sh -O /usr/local/bin/before-notebook.d/start_virtual_desktop.sh && \
    wget ${JVNC_URL}/xinitrc -O /etc/X11/xinit/xinitrc
USER ${NB_USER}

USER $NB_UID
