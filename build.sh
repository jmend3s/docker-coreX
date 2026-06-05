#!/bin/bash

# ========================================================================
# CoreX Docker Image Build Script
# ========================================================================


set -e

IMAGE_NAME="zephyr-dev"
DOCKER_DIR="docker"

docker build -t $IMAGE_NAME \
    --build-arg USER_UID=$(id -u) \
    --build-arg USER_GID=$(id -g) \
    $DOCKER_DIR/
