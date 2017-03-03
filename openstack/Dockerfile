FROM centos:7

###
# Update the system. Install stuff.
###

RUN yum update yum

RUN yum install -y vim telnet openssh openssh-clients

RUN yum install -y http://rdo.fedorapeople.org/rdo-release.rpm

RUN yum install -y python-glanceclient python-neutronclient python-novaclient python-openstackclient

ENV HOME /root

RUN mkdir -p $HOME/bin

ENV PATH=$HOME/bin:$PATH

ADD secgroup.sh $HOME/bin

ADD boot.sh $HOME/bin

ADD teardown.sh $HOME/bin

ADD unidata-ports.sh $HOME/bin

ADD mount.sh $HOME/bin

RUN chmod +x $HOME/bin/*.sh

ADD .bashrc $HOME/

WORKDIR $HOME
