#!/bin/bash
echo Make sure to:
echo  - initialize new VM
echo  - open the same ports
echo  - build or fetch relevant Docker containers
echo  - copy over the relevant configuration files. E.g., check with git diff and scrutinize ~/config
echo  - check the crontab with crontab -l
echo  - beware of any 10.0 address changes that need to be made \(e.g., NFS mounts\)
echo  - consider other ancillary stuff \(e.g., check home directory, docker-compose files\)
echo  - think before you type

read -p "Are you sure you want to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

usage="$(basename "$0") [-h] [-o, --old old VM ID] [-n, --new new VM ID] \n
    [-v, --volume zero or more volume IDs (each supplied with -v)] \n
    [-ip, --ip ip address] \n
    -- script to swap VMs:\n
    -h  show this help text\n
    -o, --old old VM ID\n
    -n, --new new VM ID\n
    -v, --volume zero or more volume IDs (each supplied with -v)\n
    -ip, --ip VM ip number\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -o|--old)
            VM_ID_OLD="$2"
            shift # past argument
            ;;
        -n|--new)
            VM_ID_NEW="$2"
            shift # past argument
            ;;
        -v|--volumes)
            VOLUME_IDS+="$2 "
            shift # past argument
            ;;
        -ip|--ip)
            IP="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$VM_ID_OLD" ];
  then
      echo "Must supply a vm name:"
      echo -e $usage
      exit 1
fi

if [ -z "$VM_ID_NEW" ];
  then
      echo "Must supply a key name:"
      echo -e $usage
      exit 1
fi

if [ -z "$IP" ];
   then
      echo "Must supply an IP address:"
      echo -e $usage
      echo openstack floating ip list
      exit 1
fi

openstack server remove floating ip ${VM_ID_OLD} ${IP}
openstack server add floating ip ${VM_ID_NEW} ${IP}

for i in ${VOLUME_IDS}
do
     openstack server remove volume ${VM_ID_OLD} $i
     openstack server add volume ${VM_ID_NEW} $i
done
