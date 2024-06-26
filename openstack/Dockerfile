FROM unidata/rockylinux:9.3.20231119

###
# Kubectl
###

RUN printf '[kubernetes]\n\
name=Kubernetes\n\
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=1\n\
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key\n'\
>> /etc/yum.repos.d/kubernetes.repo

###
# Update the system. Install stuff.
###

RUN yum install -y findutils vim telnet openssh openssh-clients git vi less \
    nano wget unzip kubectl openssl sudo python3 procps pip rsync

###
# Terraform
###

ENV TERRAFORM_VERSION=0.14.4

RUN  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

###
# Set up openstack account and create bin directory
###

RUN useradd -ms /bin/bash openstack

RUN echo "openstack ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN echo 'openstack:docker' | chpasswd

ENV HOME /home/openstack

RUN mkdir -p $HOME/bin

ENV PATH=$HOME/bin:$PATH

###
# Clone kubespray
###

RUN git clone https://github.com/zonca/jetstream_kubespray \
    $HOME/jetstream_kubespray -b branch_v2.21.0

RUN git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream  \
    $HOME/jupyterhub-deploy-kubernetes-jetstream

RUN pip3 install --upgrade pip

RUN pip3 install -r $HOME/jetstream_kubespray/requirements.txt

RUN pip3 install --upgrade python-openstackclient python-designateclient --ignore-installed

RUN mkdir $HOME/.kube

###
# Install helm
###

ENV HELM_VERSION=3.8.2

RUN cd /home \
	&& curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz \
	&& tar -xvf helm.tar.gz \
	&& rm helm.tar.gz \
	&& mv linux-amd64/helm /usr/local/bin/helm \
	&& chmod +x /usr/local/bin/helm \
	&& cd

###
# Add various utilities
###

ADD bin/boot.sh bin/mount.sh bin/secgroup.sh bin/teardown.sh \
    bin/unidata-secgroups.sh bin/swap-vm.sh bin/kube-setup.sh bin/swap-vm.sh \
    bin/kube-setup2.sh bin/kube-setup3.sh bin/remove-bloat.sh $HOME/bin/

RUN chmod +x $HOME/bin/*.sh

ADD .bashrc $HOME/

COPY ./ansible/turnoff-unneeded-services.yml /
COPY ./ansible/uninstall-packages-cleanup.yml /

###
# Finalize
###

RUN chown -R openstack:openstack $HOME/

WORKDIR $HOME

USER openstack
