#!/bin/bash

# ========================================================================
# CoreX Development Zephyr Docker Image Build Script
# ========================================================================

# This script opens a new terminal with two tabs for the container
# It work's with terminator terminal and uses xdotool to manipulate terminal commands
# If one of these tools is not installed just comment the last part of the script

# sudo apt install terminator
# sudo apt install xdotool


set -e

IMAGE_NAME="zephyr-dev"
CONTAINER_NAME="corex-zephyr-dev"
WORKSPACE_DIR="zephyr_ws"
WORKSPACE_PATH="$PWD/$WORKSPACE_DIR"
USER_NAME="jmendes"

if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Container ${CONTAINER_NAME} is already running."
else
    docker run -itd --rm \
      --name $CONTAINER_NAME \
      --hostname $CONTAINER_NAME \
      --privileged \
      -v "$WORKSPACE_PATH":/home/$USER_NAME/$WORKSPACE_DIR \
      -v /dev/bus/usb:/dev/bus/usb \
      --device=/dev/bus/usb \
      $IMAGE_NAME
fi

sleep 1

xdotool key ctrl+shift+e
sleep 0.1
xdotool type "docker exec -it corex-zephyr-dev bash -c 'cd /home/$USER_NAME/zephyr_ws; exec bash'"
xdotool key Return

xdotool key ctrl+shift+e
sleep 0.1
xdotool type "docker exec -it corex-zephyr-dev bash -c 'cd /home/$USER_NAME/zephyr_ws; exec bash'"
xdotool key Return
