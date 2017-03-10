#!/bin/sh

docker run -it  \
       -v `pwd`/.ssh/:/root/.ssh/ \
       -v `pwd`/openrc.sh:/home/openstack/bin/openrc.sh \
       openstack-client /bin/bash
