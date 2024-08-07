#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 -o|--openrc <openrc-file> -n|--name <container-name> [-s|--ssh-dir <ssh-dir>]"
    echo "  -o, --openrc    Specify the path to the openrc.sh file"
    echo "  -n, --name      Specify the name of the Docker container"
    echo "  -s, --ssh-dir   Optionally specify the path to the .ssh directory"
    echo "  -h, --help      Display this help and exit"
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--openrc)
            OPENRC_FILE="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -s|--ssh-dir)
            SSH_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate mandatory input
if [ -z "${OPENRC_FILE}" ] || [ -z "${CONTAINER_NAME}" ]; then
    echo "Error: Both --openrc and --name are required."
    show_help
    exit 1
fi

# Construct Docker command
DOCKER_CMD="docker run --name ${CONTAINER_NAME} -it "
DOCKER_CMD+=" -v $(pwd)/bin:/home/openstack/bin"
DOCKER_CMD+=" -v $(pwd)/.bashrc:/home/openstack/.bashrc"
DOCKER_CMD+=" -v ${OPENRC_FILE}:/home/openstack/bin/openrc.sh"
DOCKER_CMD+=" -v $HOME/security:/home/openstack/security"

# Optional .ssh directory
if [ -n "${SSH_DIR}" ]; then
    DOCKER_CMD+=" -v ${SSH_DIR}:/home/openstack/.ssh"
fi

DOCKER_CMD+=" unidata/science-gateway /bin/bash"

# Final Docker command to run the container
echo "Launching Docker container..."
eval "${DOCKER_CMD}"
