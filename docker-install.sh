#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

usage="$(basename "$0") [-h] [-u, --user user name] -- 
script to setup Docker. Run as root. Think before your type:\n
    -h  show this help text\n
    -u, --user User name that will be running Docker containers.\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -u|--user)
            DOCKER_USER="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$DOCKER_USER" ]; then
      echo "Must supply a user:" 
      echo -e $usage
      exit 1
fi

if [ -n "$(command -v apt-get)" ]; then
  apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade \
      && apt-get -y install git unzip wget nfs-kernel-server nfs-common
fi

if [ -n "$(command -v yum)" ]; then
  yum -y update && yum -y install git unzip wget nfs-kernel-server nfs-common
fi

curl -sSL get.docker.com | sh
usermod -aG docker ${DOCKER_USER}

curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

if [ -n "$(command -v apt-get)" ]; then
  service docker start
fi

if [ -n "$(command -v yum)" ]; then
  systemctl enable docker.service
  systemctl start docker.service
fi

reboot now
