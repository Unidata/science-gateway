###
# jupyterhub base dockerfile
###

FROM jupyterhub/jupyterhub:0.9.4


RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends curl vim zip unzip && \
    rm -rf /var/lib/apt/lists/*

###
# Setting HOME
###

ENV HOME /srv/jupyterhub

WORKDIR $HOME

###
# Install Python Stuff
###

# root environment and pip

ADD environment.yml $HOME/

ADD pip.txt $HOME/

RUN conda update --yes --quiet conda && \
    conda env update --name root -f $HOME/environment.yml && \
    pip install --upgrade pip && \
    pip install -r pip.txt

# globus environment

ADD globus_env.yml $HOME/

ADD globusconnectpersonal.patch $HOME/

RUN conda env create -f $HOME/globus_env.yml && \
    curl https://s3.amazonaws.com/connect.globusonline.org/linux/stable/globusconnectpersonal-latest.tgz | tar xz && \
    patch -p0 < globusconnectpersonal.patch && \
    rm globusconnectpersonal.patch

###
# /etc/skel
###

ADD bashrc_extra $HOME

RUN cat $HOME/bashrc_extra | tee --append /etc/skel/.bashrc > /dev/null

###
# /etc/adduser.conf
###

# To not conflict with UID, GIDs from Docker host

RUN sed -i 's/FIRST_UID=1000/FIRST_UID=1001/g' /etc/adduser.conf && \
    sed -i 's/FIRST_GID=1000/FIRST_GID=1001/g' /etc/adduser.conf

# Ensure all new users belong to docker group
# Assuming Docker host has a Docker group with GID of 999

RUN groupadd docker -g 999 && \
    sed -i 's/USERGROUPS=yes/USERGROUPS=no/g' /etc/adduser.conf && \
    sed -i 's/USERS_GID=100/USERS_GID=999/g' /etc/adduser.conf

###
# Clone Unidata Python notebook git repositories and create related conda
# environments
###

RUN mkdir -p $HOME/git

WORKDIR $HOME/git

RUN git clone https://github.com/Unidata/unidata-python-workshop && \
    git clone https://github.com/Unidata/notebook-gallery && \
    git --git-dir=notebook-gallery/.git --work-tree notebook-gallery/ \
    checkout gh-pages && git clone -b master notebook-gallery/.git \
    /tmp/notebook-gallery && \
    git clone -b master https://github.com/Unidata/online-python-training && \
    conda env update --name unidata-python-workshop \
    -f unidata-python-workshop/environment.yml && \
    conda env update --name notebook-gallery \
    -f /tmp/notebook-gallery/environment.yml && rm -rf /tmp/notebook-gallery && \
    conda env update --name online-python-training \
    -f online-python-training/environment.yml

COPY Welcome.ipynb $HOME/git

###
# Jupyter Extensions
###

# To support Dask dashboard
RUN jupyter serverextension enable --py nbserverproxy --sys-prefix

# Should be able to install extension this way, but it never works due version
# mismatches so install from source instead

# RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
#                                  @jupyterlab/hub-extension

RUN git clone https://github.com/jupyterhub/jupyterlab-hub.git \
    $HOME/jupyterlab-hub

WORKDIR $HOME/jupyterlab-hub

RUN npm install --unsafe-perm && npm run build && jupyter labextension link . && \
    git clone https://github.com/jupyter-widgets/ipywidgets.git $HOME/ipywidgets

WORKDIR $HOME/ipywidgets/packages/jupyterlab-manager

RUN npm install --unsafe-perm && npm run build && jupyter labextension link .

WORKDIR $HOME

###
# Create a few directories
###

RUN mkdir -p /etc/jupyterhub /var/log $HOME/bin

###
# Script to start JupyterHub
###

COPY runjupyter.sh $HOME/bin

RUN chmod +x $HOME/bin/runjupyter.sh

##
# Set the path
##

ENV PATH /srv/jupyterhub/bin:$PATH

##
# Execute script.
##

CMD ["runjupyter.sh"]
