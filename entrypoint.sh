#!/bin/bash

# ========================================================================
# CoreX Zephyr Development Container Entrypoint
# ========================================================================


set -e

USER="jmendes"
ZEPHYR_HEX="/home/$USER/zephyr_ws/build/zephyr/zephyr.hex"

{
  echo "alias build=\"west build -p -b teensy41 -S cdc-acm-console\""
  echo "alias flash=\"sudo teensy_loader_cli -mmcu=TEENSY41 -w $ZEPHYR_HEX\""
  echo "alias monitor=\"sudo minicom -D /dev/ttyACM1 -b 115200\""

  echo "export ZEPHYR_EXTRA_MODULES=/home/$USER/zephyr_ws/corekit"
} >> /home/$USER/.bashrc

exec "$@"
