FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN apt-get update
RUN apt install -y build-essential libc6-dev nodejs npm

RUN pip install notebook jupyterlab jupyter-c-kernel clang
RUN install_c_kernel --prefix=/srv/venv

#RUN npm install -g ijavascript
#RUN ijsinstall --install=global

RUN npm install -g tslab
RUN tslab install --python=python3

RUN apt install -y r-cran-irkernel

RUN pip install kotlin-jupyter-kernel

RUN    apt-get install -y \
        openjdk-17-jdk \
        wget \
        unzip && \
    cd /tmp && \
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip ijava-1.3.0.zip -d ijava && \
    cd ijava && \
    python3 install.py --sys-prefix && \
    rm -rf /tmp/ijava*
    
# Clojure CLI
RUN curl -L https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
    -o /tmp/linux-install.sh && \
    chmod +x /tmp/linux-install.sh && \
    /tmp/linux-install.sh

# Install clojupyter
RUN clojure -Ttools install-latest \
    :lib io.github.clojupyter/clojupyter \
    :as clojupyter

# Register kernel
RUN clojure -M -m clojupyter.cmdline install --ident clojure

#
# Rust + evcxr kernel
#
#RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

#ENV PATH="/root/.cargo/bin:${PATH}"

#RUN cargo install evcxr_jupyter && \
#    evcxr_jupyter --install

#
# Go kernel
#
#RUN go install github.com/gopherdata/gophernotes@latest

#RUN mkdir -p /usr/local/share/jupyter/kernels/gophernotes && \
#    cp $(go env GOPATH)/bin/gophernotes /usr/local/bin/

#
# .NET Interactive
# Provides:
# - C#
# - F#
# - PowerShell
#
#RUN dotnet tool install --global Microsoft.dotnet-interactive

#ENV PATH="${PATH}:/root/.dotnet/tools"

#RUN dotnet interactive jupyter install

#RUN cp -r /root/.local/share/jupyter/kernels/c /srv/venv/share/jupyter/kernels/

RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py

#RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
#    bash /tmp/miniconda.sh -bfp /usr/local && \
#    rm -rf /tmp/miniconda.sh  && \
#    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
#    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
#    conda install -y python=3 && \
#    conda update conda && \
#    conda clean --all --yes && \
#    conda clean --force-pkgs-dirs -y

#RUN conda install -c conda-forge xeus-cling xeus-sqlite xeus-sql
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp11 --sys-prefix
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp14 --sys-prefix
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp17 --sys-prefix

#RUN conda install -c conda-forge bash_kernel

#RUN conda install -c conda-forge ipywidgets beakerx

#RUN conda install -c conda-forge xeus-sqlite
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xsqlite --sys-prefix

#RUN conda install -c conda-forge xeus-sql
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xsql --sys-prefix

#RUN conda install -c conda-forge xeus-r

#RUN conda install -c conda-forge kotlin-jupyter-kernel

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
