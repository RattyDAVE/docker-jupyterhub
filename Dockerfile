FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

#
# Base packages and R Kernel
#
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libc6-dev \
        nodejs \
        npm \
        openjdk-17-jdk \
        wget \
        unzip \
        curl \
        r-cran-irkernel && \
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
        kotlin-jupyter-kernel \
        bash_kernel

#
# C Kernel
#
RUN install_c_kernel --prefix=/srv/venv

#
# Bash Kernel
#
RUN python -m bash_kernel.install

#
# TypeScript + JavaScript
#
RUN npm install -g tslab && \
    tslab install --python=python3

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
# Rust
#
ENV CARGO_HOME=/opt/cargo
ENV RUSTUP_HOME=/opt/rustup
ENV PATH=/opt/cargo/bin:$PATH

RUN mkdir -p /opt/cargo /opt/rustup

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN rustup default stable

RUN cargo install evcxr_jupyter --version 0.20.0

RUN evcxr_jupyter --install

#
# Make Rust kernel available to all users
#
RUN mkdir -p /srv/venv/share/jupyter/kernels && \
    cp -r /root/.local/share/jupyter/kernels/rust \
          /srv/venv/share/jupyter/kernels/

RUN sed -i \
    's#/root/.cargo/bin/evcxr_jupyter#/opt/cargo/bin/evcxr_jupyter#' \
    /srv/venv/share/jupyter/kernels/rust/kernel.json

#
# Make C kernel available to all users
#
RUN cp -r \
      /root/.local/share/jupyter/kernels/c \
      /srv/venv/share/jupyter/kernels/ || true

#
# Verify Rust installation during build
#
RUN rustc --version && \
    cargo --version && \
    rustup show

#
# JupyterHub Configuration
#
RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
