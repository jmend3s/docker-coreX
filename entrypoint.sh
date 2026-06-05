#!/bin/bash

# ========================================================================
# [PROJECT NAME] Container Entrypoint
# ========================================================================


set -e

USER="[USERNAME]"

{
  echo "alias [COMMAND ALIAS]=\"[COMMAND]\""
  echo "alias [COMMAND ALIAS]=\"[COMMAND]\""
} >> /home/$USER/.bashrc

exec "$@"
