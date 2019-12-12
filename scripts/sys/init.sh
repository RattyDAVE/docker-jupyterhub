#!/usr/bin/env bash

export M2_HOME=/usr/share/maven
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

mkdir -p ~/.jupyter
mkdir -p ~/.local/share/jupyter/runtime

codemirror_dir=~/.jupyter/lab/user-settings/@jupyterlab/codemirror-extension
mkdir -p $codemirror_dir
cp /settings/commands.jupyterlab-settings $codemirror_dir

apputils_dir=~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
mkdir -p $apputils_dir
cp /settings/themes.jupyterlab-settings $apputils_dir

source /scripts/sys/launch.sh 
