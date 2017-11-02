###
# jupyterhub base dockerfile
###

FROM jupyterhub/jupyterhub:latest

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y curl vim zip unzip
###
# Setting HOME
###

ENV HOME /srv/jupyterhub

WORKDIR $HOME

###
# Install Python Stuff
###

# root environment

RUN conda update --yes --quiet conda

ADD environment.yml $HOME/

RUN conda env update --name root -f $HOME/environment.yml

ADD pip.txt $HOME/

RUN pip install -r pip.txt

# globus environment

ADD globus_env.yml $HOME/

RUN conda env create -f $HOME/globus_env.yml

RUN curl https://s3.amazonaws.com/connect.globusonline.org/linux/stable/globusconnectpersonal-latest.tgz | tar xz

ADD globusconnectpersonal.patch $HOME/

RUN patch -p0 < globusconnectpersonal.patch

RUN rm globusconnectpersonal.patch

###
# /etc/skel
###

ADD bashrc_extra $HOME

RUN cat $HOME/bashrc_extra | tee --append /etc/skel/.bashrc > /dev/null

###
# /etc/adduser.conf
###

# To not conflict with UID, GIDs from Docker host

RUN sed -i 's/FIRST_UID=1000/FIRST_UID=1001/g' /etc/adduser.conf

RUN sed -i 's/FIRST_GID=1000/FIRST_GID=1001/g' /etc/adduser.conf

# Ensure all new users belong to docker group
# Assuming Docker host has a Docker group with GID of 999

RUN groupadd docker -g 999

RUN sed -i 's/USERGROUPS=yes/USERGROUPS=no/g' /etc/adduser.conf

RUN sed -i 's/USERS_GID=100/USERS_GID=999/g' /etc/adduser.conf

###
# Clone Unidata Python notebook git repositories
###

RUN mkdir -p $HOME/git

WORKDIR $HOME/git

RUN git clone https://github.com/Unidata/unidata-python-workshop 
RUN git clone https://github.com/Unidata/notebook-gallery
RUN git clone -b master https://github.com/Unidata/online-python-training

COPY Welcome.ipynb $HOME/git

WORKDIR $HOME

###
# Create a few directories
###

RUN mkdir -p /etc/jupyterhub /var/log 

###
# Script to start JupyterHub
###

RUN mkdir -p $HOME/bin

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
