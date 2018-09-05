#Create new VM - Jetstream/Horizon - 
#Source open stack credential



if [ "$#" -lt 1 ]
then
echo "$(tput setaf 2)Please specify node name as indicated in example below (don't include [ ]): $(tput sgr 0)"
echo "$(tput setaf 1)createInstance.sh [JetStreamNode1] $(tput sgr 0)"
exit 1
fi

NodeName=$1
source /Users/Semir/Downloads/TG-XXXXXX-openrc.sh

# create a VM - Ubuntu 16.04 (ubuntu-16.04-xenial-cloudimage-20160830)
openstack server create $NodeName --flavor m1.small --image ubuntu-16.04-xenial-cloudimage-20160830 --key-name NAME_of_Your_Key --security-group NAME_of_Security_Group-ssh --nic net-id=Name_of-api-net

# add a floating IP
generateIP=`openstack floating ip create public`
instanceIP=`echo $instanceIP | sed 's/^.*floating_ip_address/floating_ip_address/' | awk '{print $3}'`
openstack server add floating ip $NodeName $instanceIP
