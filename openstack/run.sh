#!/bin/bash -f
dir="$( cd "$(dirname "$0")" ; pwd -P )"
echo $dir

if [ ! -d $dir/ssh ]; then
  mkdir $dir/ssh
  chmod 777 $dir/ssh # write access required for keygen
fi

./openstack.sh -o ${dir}/bin -s ${dir}/ssh
