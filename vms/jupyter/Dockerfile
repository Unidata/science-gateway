###
# jupyterhub base dockerfile
###

FROM jupyterhub/jupyterhub:latest

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y curl

###
# Setting HOME
###

ENV HOME /srv/jupyterhub

WORKDIR $HOME

###
# Install Python Stuff
###

RUN conda update --yes --quiet conda

ADD environment.yml $HOME/

RUN conda env update --name root -f $HOME/environment.yml

RUN pip install python-awips mpldatacursor oauthenticator

###
# /etc/skel
###

RUN echo | tee --append /etc/skel/.bashrc > /dev/null
RUN echo "# cd to notebook directory upon login" | tee --append /etc/skel/.bashrc > /dev/null
RUN echo "cd /notebooks/\$USER" | tee --append /etc/skel/.bashrc > /dev/null

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
