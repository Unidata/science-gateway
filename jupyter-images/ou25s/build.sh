#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

usage() {
    echo "Usage: $0 <image-name> [--push]"
    echo "  <image-name>  Name of the Docker image to build"
    echo "  --push        Optionally push the Docker image to DockerHub"
    exit 1
}

if [ -z "$1" ]; then
    echo "Error: No image name provided."
    usage
fi

IMAGE_NAME=$1
PUSH_IMAGE=false

if [ "$2" == "--push" ]; then
    PUSH_IMAGE=true
fi

DATE_TAG=$(date "+%Y%b%d_%H%M%S")
RANDOM_HEX=$(openssl rand -hex 2)
TAG="${DATE_TAG}_${RANDOM_HEX}"
FULL_TAG="unidata/$IMAGE_NAME:$TAG"

# Build the Docker image
echo "Building Docker image with tag: $FULL_TAG"
docker build --no-cache --pull --tag "$FULL_TAG" .

echo "Docker image built successfully: $FULL_TAG"

if $PUSH_IMAGE; then
    echo "Pushing Docker image to DockerHub: $FULL_TAG"
    docker push "$FULL_TAG"
    echo "Docker image pushed successfully: $FULL_TAG"
else
    echo "Skipping Docker image push. Use '--push' to push the image."
fi

exit 0
