#!/bin/bash

# Function to display usage guide
usage() {
    cat <<EOF
Usage: $0 options

This script deploys a virtual machine in an OpenStack environment.

OPTIONS:
   -n   --name            Set the VM name
   -c   --security-script Path to the security script
   -g   --security-groups Security groups to add (comma-separated, e.g., global-www,global-tomcat)
   -i   --image           The image to use (default: RockyLinux Featured Image)
   -s   --size            VM size
   -k   --key             SSH Key Name
   -ip, --ip IP_ADDRESS   IP address for VM.
   -h   --help            Show this message
EOF
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -n|--name) VM_NAME="$2"; shift ;;
        -c|--security-script) SECURITY_SCRIPT="$2"; shift;;
        -g|--security-groups) SECURITY_GROUPS="$2"; shift ;;
        -i|--image) IMAGE_NAME="$2"; shift ;;
        -s|--size) VM_SIZE="$2"; shift ;;
        -k|--key) KEY_NAME="$2"; shift ;;
       -ip|--ip) IP="$2"; shift ;;
        -h|--help) usage; exit ;;
        *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
    esac
    shift
done

# Validate required parameters
if [[ -z "$VM_NAME" ]]; then
    echo "Error: Must supply a VM name."
    usage
    exit 1
fi

if [[ -z "$KEY_NAME" ]]; then
    echo "Error: Must supply a key name."
    usage
    exit 1
fi

if [[ -z "$VM_SIZE" ]]; then
    echo "Error: Must supply a VM size."
    usage
    openstack flavor list
    exit 1
fi

if [[ -z "$SECURITY" ]]; then
	echo "Security script not specifed, defaulting to $HOME/security/security.sh"
	SECURITY="$HOME/security/security.sh"
fi

# Set a default image name if not provided
if [[ -z "$IMAGE_NAME" ]]; then
    # Attempt to find a RockyLinux Featured Image
    IMAGE_NAME=$(openstack image list | grep -i featured | grep -i rocky \
                 | awk 'BEGIN { FS = "|" } ; { print $2 }' | tail -1)
    echo "No image name supplied, using ${IMAGE_NAME}."
fi

# obtained through openstack network list
NETWORK_ID=unidata-public

# Openstack server creation command
openstack server create "$VM_NAME" \
  --flavor "$VM_SIZE" \
  --image "$IMAGE_NAME" \
  --key-name "$KEY_NAME" \
  --nic net-id=$"$NETWORK_ID" \
  --user-data "$SECURITY_SCRIPT"

# give chance for VM to fire up
echo sleep 30 for seconds while VM fires up
sleep 30

openstack server remove security group "$VM_NAME" default

# Add security groups to the VM
if [[ -n "$SECURITY_GROUPS" ]]; then
    IFS=',' read -ra ADDR <<< "$SECURITY_GROUPS"
    for group in "${ADDR[@]}"; do
        openstack server add security group "$VM_NAME" "$group"
    done
else
    # Default security group if none specified
    openstack server add security group "$VM_NAME" global-ssh-22
fi

# Assign an IP if provided
if [[ -n "$IP" ]]; then
    openstack server add floating ip "$VM_NAME" "$IP"
fi
