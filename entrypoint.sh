#!/bin/bash

# ========================================================================
# CoreX Zephyr Development Container Entrypoint
# ========================================================================


set -e

export PATH=$HOME/.local/bin:$PATH
export ZEPHYR_BASE=$HOME/zephyrproject/zephyr
export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

USER="jmendes"
ZEPHYR_HEX="/home/$USER/zephyr_ws/build/zephyr/zephyr.hex"

{
  echo "alias buildTeensy41=\"west build -p -b teensy41 -S cdc-acm-console\""
  echo "alias buildSupermini=\"west build -p -b esp32c3_supermini\""

  echo "alias flashTeensy=\"sudo teensy_loader_cli -mmcu=TEENSY41 -w $ZEPHYR_HEX\""
  echo "alias flashSupermini=\"west flash --esp-device /dev/ttyACM0\""

  echo "alias monitorTeensy=\"sudo minicom -D /dev/ttyACM1 -b 115200\""
  echo "alias monitorSupermini=\"sudo minicom -D /dev/ttyACM0 -b 115200\""

  echo "export ZEPHYR_EXTRA_MODULES=/home/$USER/zephyr_ws/corekit"
} >> /home/$USER/.bashrc

exec "$@"
