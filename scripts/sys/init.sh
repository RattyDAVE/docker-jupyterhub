#!/usr/bin/env bash

# create a user

/scripts/sys/etc.sh pre

# su -m $DOCKER_USER -c /scripts/launch.sh
source /scripts/sys/launch.sh 
# /scripts/sys/etc.sh post
