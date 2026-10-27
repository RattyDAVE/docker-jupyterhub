FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN pip install notebook jupyterlab

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

RUN apt-get update
RUN apt install -y build-essential libc6-dev

RUN pip install jupyter-c-kernel
RUN install_c_kernel

#RUN conda install -c conda-forge xeus-cling xeus-sqlite xeus-sql
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp11 --sys-prefix
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp14 --sys-prefix
#RUN jupyter kernelspec install PREFIX/share/jupyter/xcpp17 --sys-prefix

#/usr/local/share/jupyter/kernels
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xcpp11 --sys-prefix
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xcpp14 --sys-prefix
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xcpp17 --sys-prefix

RUN conda install -c conda-forge bash_kernel

#RUN conda install -c conda-forge ipywidgets beakerx

#RUN conda install -c conda-forge xeus-sqlite
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xsqlite --sys-prefix

#RUN conda install -c conda-forge xeus-sql
#RUN jupyter kernelspec install /usr/local/share/jupyter/kernels/xsql --sys-prefix

#RUN conda install -c conda-forge xeus-r

#RUN conda install -c conda-forge kotlin-jupyter-kernel

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
