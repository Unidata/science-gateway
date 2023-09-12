# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# open stack aliases

alias ofl='openstack floating ip list'
alias ofc='openstack floating ip create public'
alias osl='openstack server list'
alias onl='openstack network list'
alias ovl='openstack volume list'
alias k='kubectl'
alias kctl='kubectl'
alias sshmain='ssh ubuntu@$IP -L 6443:localhost:6443'
alias h='history'
alias hist='history'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

source /home/openstack/bin/openrc.sh

echo ensure open stack is working with: openstack image list
echo https://iujetstream.atlassian.net/wiki/display/JWT/OpenStack+command+line

echo You will find cluster.tf here:
find /home/openstack -name cluster.tf\*

worker ()
{
 # SSH into a worker node of a JupyterHub cluster by jumping through the main node
 # Usage: worker <N>
 WORKER_N=$1
 PRIVATE_IP=$(kubectl get nodes -o custom-columns="NAME:.metadata.name,INTERNAL-IP:.status.addresses[?(@.type=='InternalIP')].address" | grep -e "node-nf-${WORKER_N}" | awk '{print $2}')
 if [ -n "$PRIVATE_IP" ]; then
  ssh ubuntu@$PRIVATE_IP -J ubuntu@${IP}
 else
  echo "Worker $WORKER_N doesn't exist, try one of these:"
  kubectl get nodes -o wide
 fi
}
