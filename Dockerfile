FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN pip install notebook jupyterlab

RUN pip3 install jupyter-c-kernel install_c_kernel

RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py


RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -bfp /usr/local && \
    rm -rf /tmp/miniconda.sh  && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda install -y python=3 && \
    conda update conda && \
    conda clean --all --yes && \
    conda clean --force-pkgs-dirs -y

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
