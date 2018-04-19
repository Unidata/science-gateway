#!/bin/bash
openstack security group create --description "wrangler & icmp enabled" wrangler

WRANGLER_IP=149.165.238.47

for i in 111 875 892 2049 10053 32803
do
    openstack security group rule create wrangler --protocol tcp \
              --dst-port $i:$i --remote-ip ${WRANGLER_IP}
    openstack security group rule create wrangler --protocol udp \
              --dst-port $i:$i --remote-ip ${WRANGLER_IP}
done

openstack security group rule create wrangler --protocol icmp
