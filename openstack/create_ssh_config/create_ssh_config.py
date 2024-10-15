#! /usr/bin/env conda run -n create_ssh_config python

import openstack
import sshconf

from os.path import expanduser
home = expanduser('~')

# gate setup
gate_host = 'gate.unidata.ucar.edu'
gate_user = '<gate-user>' # Change me :)
forward_port = 7824 # Will be incremented for each LocalForward gate entry
LocalForward=[]

# sshconf setup
key_file = home+'/.ssh/<key-file-name>' # Change me :)
ssh_port = 22
output_file = home+'/.ssh/openstack-config'

c = sshconf.empty_ssh_config_file()

# fetch openstack server list
conn = openstack.connect(cloud='openstack')
servers = conn.list_servers()

# Add openstack servers to ssh config file
for server in servers:
    s = server.to_dict()
    if s['interface_ip']:
        if 'ssh_user' in s['metadata']:
            user = s['metadata']['ssh_user']
        else:
            user = 'rocky'
        # Prepare to add gate tunnel
        LocalForward.append('{} {}:{}'.format(forward_port,s['interface_ip'],ssh_port))
        # Add "regular" entry
        c.add(s['hostname'], Hostname=s['interface_ip'], User=user, Port=ssh_port, IdentityFile=key_file)
        # Add "tunnel" entry
        c.add(s['hostname']+"-tun", Hostname='localhost', User=user, Port=forward_port, IdentityFile=key_file)
        # Increment
        forward_port += 1

c.add('gate', Hostname=gate_host, User=gate_user, LocalForward=LocalForward)

c.write(output_file)
