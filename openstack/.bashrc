# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# open stack aliases

alias ofl='openstack floating ip list'
alias osl='openstack server list'
alias onl='openstack network list'
alias ovl='openstack volume list'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

source /home/openstack/bin/openrc.sh

echo ensure open stack is working with: openstack image list
echo https://iujetstream.atlassian.net/wiki/display/JWT/OpenStack+command+line

echo You will find cluster.tf here:
find /home/openstack -name cluster.tf\*
