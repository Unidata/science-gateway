#!/bin/sh

docker run -it  \
       -v `pwd`/.ssh/:/root/.ssh/ \
       -v `pwd`/openrc.sh:/root/bin/openrc.sh \
       openstack-client /bin/bash
