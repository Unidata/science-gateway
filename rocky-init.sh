#!/bin/bash

usage="
Usage: sudo ./rocky-init.sh [-d, --docker-user \$USER ] [ -n, --nfs ]\n
Include --docker and/or --nfs flags to optionally install docker/docker-compose\n
and/or docker compose"

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: Must run as root"
  echo -e $usage
  exit 1
fi

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -d|--docker-user)
            DOCKER_USER="$2"
            shift # past argument
            ;;
        -n|--nfs)
            INSTALL_NFS=1
			# Shift only once at the end of this loop iteration
            ;;
    esac
    shift # past argument or value
done

# When running as root (using sudo), $(id -u -n) evaluates to "root" instead of
# the user we want to be added to the "docker" group
# DOCKER_USER=$(id -u -n)
DOCKER_USER=$1

systemctl stop docker

###
# yum upgrades
###

# Remove any existing packages that may conflict with the installation
yum -y remove docker docker-common docker-selinux docker-engine-selinux \
  docker-engine docker-ce podman buildah && rm -rf /var/lib/docker

# Upgrade existing packages and install the Extra Packages for Enterprise Linux repo
yum -y upgrade && yum install -y epel-release

# Desired packages for basic use
yum install -y sudo man man-pages vim nano git wget unzip ncurses procps htop \
	python3 telnet openssh openssh-clients openssl findutils \
	tmux

# NFS install
if [ -v INSTALL_NFS ];
then
	echo "NFS flag supplied: Installing NFS..."
	yum install -y nfs-kernel-server nfs-common
fi

###
# docker installation
###
if [ -z "$DOCKER_USER" ];
then
	echo "Docker user flag supplied: Installing docker and docker-compose..."
	# Convenience script doesn't support rocky, but we can still install everything manually
	# from the centOS repo
	# curl -sSL get.docker.com | sh
	yum install -y yum-utils
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce docker-ce-cli containerd.io

	groupadd docker
	usermod -aG docker ${DOCKER_USER}

	# Install docker-compose (v2 acts as a plugin to the docker CLI)
	DOCKER_CONFIG=${DOCKER_CONFIG:-/home/$DOCKER_USER/.docker}
	mkdir -p $DOCKER_CONFIG/cli-plugins
	curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

	# Make $USER the owner of the created directory, and make the plugin executable
	chown -R $DOCKER_USER:$DOCKER_USER $DOCKER_CONFIG
	chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

	# Only necessary for docker-compose v1
	# chmod +x /usr/local/bin/docker-compose

	systemctl enable docker.service
	systemctl start docker.service

	mkdir /logs
	chown -R ${DOCKER_USER}:docker /logs
fi

reboot now
