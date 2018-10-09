FROM centos:7

###
# Update the system. Install stuff.
###

RUN yum update yum -y

RUN yum install -y vim telnet openssh openssh-clients git vi less nano

RUN yum install -y http://rdo.fedorapeople.org/rdo-release.rpm

RUN yum install -y python-glanceclient python-openstackclient

###
# Set up openstack account and create bin directory
###

RUN useradd -ms /bin/bash openstack

ENV HOME /home/openstack

RUN mkdir -p $HOME/bin

ENV PATH=$HOME/bin:$PATH

###
# Add various utilities
###

ADD bin/boot.sh bin/mount.sh bin/secgroup.sh bin/teardown.sh \
   bin/unidata-secgroups.sh bin/wrangler-jetstream.sh bin/wrangler-secgroup.sh \
   bin/swap-vm.sh $HOME/bin/

RUN chmod +x $HOME/bin/*.sh

ADD .bashrc $HOME/

###
# Finalize
###

RUN chown -R openstack:openstack $HOME/

WORKDIR $HOME

USER openstack
