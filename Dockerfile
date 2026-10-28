FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libc6-dev \
        nodejs \
        npm \
        openjdk-17-jdk \
        wget \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# Python + JupyterLab
#
RUN pip install --no-cache-dir \
    notebook \
    jupyterlab \
    jupyter-c-kernel \
    clang \
    kotlin-jupyter-kernel

#
# C Kernel
#
RUN install_c_kernel --prefix=/srv/venv

#
# TypeScript Kernel
#
RUN npm install -g tslab
RUN tslab install --python=python3

#
# R Kernel
#
RUN apt-get update && \
    apt-get install -y r-cran-irkernel

#
# Java Kernel (IJava)
#
RUN cd /tmp && \
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip ijava-1.3.0.zip -d ijava && \
    cd ijava && \
    python3 install.py --sys-prefix && \
    rm -rf /tmp/ijava*

#
# JupyterHub Configuration
#
RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
