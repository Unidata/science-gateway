FROM unidata/rockylinux:9.3.20231119

ARG TERRAFORM_VERSION=0.14.4
ARG HELM_VERSION=3.8.1

ENV HOME=/home/openstack \
    PATH=/home/openstack/bin:$PATH

RUN mkdir -p /home/openstack/bin /home/openstack/.config/nushell

COPY ansible/*.yml /
COPY bin/*.sh /home/openstack/bin/
COPY bin/*.nu /home/openstack/bin/
COPY .bashrc /home/openstack/
COPY nu/ /home/openstack/.config/nushell/

RUN set -euxo pipefail && \
printf "[gemfury-nushell] \n\
name=Gemfury Nushell Repo \n\
baseurl=https://yum.fury.io/nushell/ \n\
enabled=1 \n\
gpgcheck=0 \n\
gpgkey=https://yum.fury.io/nushell/gpg.key" | tee /etc/yum.repos.d/fury-nushell.repo &&  \
printf '[kubernetes]\n\
name=Kubernetes\n\
baseurl=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=0\n\
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/repodata/repomd.xml.key\n' \
    > /etc/yum.repos.d/kubernetes.repo && \
    dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y \
        less kubectl pip rsync jq python3 nushell && \
    dnf clean all && rm -rf /var/cache/dnf && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | \
        tar -xz -C /usr/local/bin --strip-components=1 linux-amd64/helm && \
    useradd -ms /bin/bash openstack && \
    echo 'openstack:docker' | chpasswd && \
    echo 'openstack ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/openstack && \
    git clone https://github.com/zonca/jetstream_kubespray \
        /home/openstack/jetstream_kubespray -b branch_v2.21.0 && \
    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream \
        /home/openstack/jupyterhub-deploy-kubernetes-jetstream && \
    pip3 install --upgrade pip && \
    pip3 install -r /home/openstack/jetstream_kubespray/requirements.txt && \
    pip3 install --upgrade \
        'python-openstackclient==8.0.0' \
        'python-magnumclient==4.8.1' \
        'python-octaviaclient==3.11.0' \
        'python-designateclient==6.3.0' --ignore-installed && \
    chown -R openstack:openstack /home/openstack && \
    chmod +x /home/openstack/bin/*.sh

WORKDIR /home/openstack
USER openstack
