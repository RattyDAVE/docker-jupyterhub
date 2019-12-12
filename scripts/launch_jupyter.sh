#!/bin/bash

export DOCKER_USER=$(id -un)
/scripts/sys/etc.sh pre 039
NOTEBOOK_DIR=/workdir
if [[ $(id -un) == gitpod ]]; then
    NOTEBOOK_DIR=/workspace
fi
jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=$NOTEBOOK_DIR &
/scripts/sys/etc.sh post 039
sleep 5
/scripts/list_jupyter.py
