#!/bin/bash
usage="$(basename "$0") [-h] [-v, --vm vm id] [-n, --nic wrangler network id] --
  script to setup vm for Wrangler access:\n
      -h  show this help text\n
      -v, --vm vm id\n
      -n, --nic wrangler network id\n"

  while [[ $# > 0 ]]
  do
      key="$1"
      case $key in
          -v|--vm)
              VM_ID="$2"
              shift # past argument
              ;;
          -n|--nic)
              NIC_ID="$2"
              shift # past argument
              ;;
          -h|--help)
              echo -e $usage
              exit
              ;;
      esac
      shift # past argument or value
  done

if [ -z "$VM_ID" ];
  then
      echo "Must supply a VM ID:"
      echo -e $usage
      exit 1
fi

if [ -z "$NIC_ID" ];
  then
      echo "Must supply a network ID:"
      echo -e $usage
      exit 1
fi

openstack server add network ${VM_ID} ${NIC_ID}

openstack server add security group ${VM_ID} wrangler
