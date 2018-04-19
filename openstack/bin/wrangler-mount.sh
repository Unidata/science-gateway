#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


usage="$(basename "$0") [-h] [-e, --ens network interface] [-m, --mount dir] --
script to create Unidata mount from Wrangler to Jetstream:\n
    -h  show this help text\n
    -e, --ens network interface\n
    -m, --mount mount point\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -e|--ens)
            ENS="$2"
            shift # past argument
            ;;
        -m|--mount)
            MOUNT="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z "$ENS" ];
  then
      echo "Must supply a network interface:"
      echo -e $usage
      exit 1
fi

if [ -z "$MOUNT" ];
  then
      echo "Must supply a mount point:"
      echo -e $usage
      exit 1
fi

echo rpcbind : 10.5.0.96/28 127.0.0.1 | tee --append /etc/hosts.allow > /dev/null

cat <<EOF >> /etc/network/interfaces

# Wrangler network
auto ${ENS}
iface ${ENS} inet dhcp
EOF

echo SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", \
     ATTR{address}==\"fa:16:3e:f8:cf:ea\", NAME=\"${ENS}\" \
    | tee --append /etc/udev/rules.d/70-persistent-net.rules > /dev/null

ifup ${ENS}

mkdir -p ${MOUNT}

mount -v -t nfs iuwrang-c111.uits.indiana.edu:/data/projects/G-818573 \
      ${MOUNT} -o rsize=131072,wsize=131072,timeo=300,hard,vers=3

echo iuwrang-c111.uits.indiana.edu:/data/projects/G-818573 ${MOUNT} \
     nfs rsize=131072,wsize=131072,timeo=300,hard,nofail \
    | tee --append /etc/fstab > /dev/null
