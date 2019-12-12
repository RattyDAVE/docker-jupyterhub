#!/usr/bin/env bash

export HOME=/home/$DOCKER_USER # do NOT remove!!! Necessary for it to work.
cd $HOME

mkdir -p $HOME/.jupyter
chown -R $DOCKER_USER:$DOCKER_GROUP $HOME/.jupyter

# .local directory
mkdir -p $HOME/.local/share/jupyter/runtime
chown -R $DOCKER_USER:$DOCKER_GROUP $HOME/.local
