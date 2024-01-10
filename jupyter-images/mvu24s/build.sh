#!/bin/bash

# Check if an image name is provided
if [ -z "$1" ]; then
    echo "Error: No image name provided."
    echo "Usage: $0 <image-name>"
    exit 1
fi

IMAGE_NAME=$1

DATE_TAG=$(date "+%Y%b%d_%H%M%S")
RANDOM_HEX=$(openssl rand -hex 2)
TAG="${DATE_TAG}_${RANDOM_HEX}"

FULL_TAG="unidata/$IMAGE_NAME:$TAG"

echo "Building Docker image with tag: $FULL_TAG"

docker build --no-cache --pull --tag "$FULL_TAG" .

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image built successfully: $FULL_TAG"
else
    echo "Error: Docker build failed."
    exit 1
fi
