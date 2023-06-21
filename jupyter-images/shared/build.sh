# /bin/bash

IMAGE_NAME=$1
TAG="$(date +%Y%b%d_%H%M%S)_$(openssl rand -hex 4)"

docker build --tag unidata/$IMAGE_NAME:$TAG .
