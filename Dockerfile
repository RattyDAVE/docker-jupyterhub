FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

#
# Base packages
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
# Python + Jupyter
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
# TypeScript / JavaScript
#
RUN npm install -g tslab && \
    tslab install --python=python3

#
# Java (IJava)
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

RUN mkdir -p /opt/cargo /opt/rustup && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup default stable && \
    cargo install evcxr_jupyter --version 0.20.0 && \
    evcxr_jupyter --install

#
# Rust kernel for JupyterHub users
#
RUN mkdir -p /srv/venv/share/jupyter/kernels && \
    cp -r /root/.local/share/jupyter/kernels/rust \
          /srv/venv/share/jupyter/kernels/

RUN cat > /srv/venv/share/jupyter/kernels/rust/kernel.json << 'EOF'
{
  "argv": [
    "/opt/cargo/bin/evcxr_jupyter",
    "--control_file",
    "{connection_file}"
  ],
  "display_name": "Rust",
  "language": "rust",
  "interrupt_mode": "message",
  "env": {
    "PATH": "/opt/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "CARGO_HOME": "/opt/cargo",
    "RUSTUP_HOME": "/opt/rustup"
  }
}
EOF

#
# Make Rust commands visible to all users
#
RUN ln -sf /opt/cargo/bin/rustc /usr/local/bin/rustc && \
    ln -sf /opt/cargo/bin/cargo /usr/local/bin/cargo && \
    ln -sf /opt/cargo/bin/rustup /usr/local/bin/rustup && \
    ln -sf /opt/cargo/bin/evcxr_jupyter /usr/local/bin/evcxr_jupyter

#
# Make C kernel available to all users
#
RUN cp -r \
      /root/.local/share/jupyter/kernels/c \
      /srv/venv/share/jupyter/kernels/ || true

#
# JupyterHub config
#
RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py

ADD https://github.com/jakevdp/PythonDataScienceHandbook/archive/refs/heads/master.zip /tmp
RUN unzip /tmp/master.zip -d /etc/skel && rm /tmp/master.zip

ADD https://github.com/8greg8/interactive_c_tutorial/archive/refs/heads/master.zip /tmp
RUN unzip /tmp/master.zip -d /etc/skel && rm /tmp/master.zip




EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
