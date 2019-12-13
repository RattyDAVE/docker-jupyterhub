FROM ubuntu:19.04

RUN apt-get update -y && \ 
    apt-get install -y --no-install-recommends sudo nodejs npm curl && \
    curl https://www.npmjs.com/install.sh | sudo sh && npm install -g n && n 12.13.0 && \
    apt-get install -y python3 python3-pip python3-venv python3-all-dev python3-setuptools build-essential python3-wheel openjdk-8-jdk maven gradle git libtinfo5 wget julia && \
    mkdir -p /workdir && chmod 777 /workdir && \
    pip3 install --no-cache-dir mypy pylint yapf pytest ipython tornado jupyter nbdime jupyterlab jupyter-lsp python-language-server[all] jupyterhub bash_kernel markdown-kernel \
                                torch torchvision tensorflow keras h2o gensim pytext-nlp loguru pysnooper numpy scipy pandas pyarrow>=0.14.0 dask[complete] scikit-learn xgboost \
                                matplotlib bokeh holoviews[recommended] hvplot tabulate JPype1==0.6.3 JayDeBeApi sqlparse requests[socks] lxml notifiers py4j beakerx && \
\
     beakerx install && \
     python3 -m bash_kernel.install && \
     python3 -m markdown_kernel.install && \
     jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
     jupyter labextension install beakerx-jupyterlab && \
     jupyter labextension install @pyviz/jupyterlab_pyviz  && \
     jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
     jupyter labextension install @jupyterlab/toc && \
     jupyter labextension install jupyterlab-favorites && \
     jupyter labextension install jupyterlab-recents && \
     jupyter labextension install @krassowski/jupyterlab-lsp  && \
\
#Julia && \
    julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("IJulia")'  && \
    cp -r /root/.local/share/jupyter/kernels/julia-* /usr/local/share/jupyter/kernels/  && \
    chmod -R +rx /usr/share/julia/  && \
    chmod -R +rx /usr/local/share/jupyter/kernels/julia-*/  && \
#C++ && \
    mkdir -p ~/pre && cd ~/pre && \
    wget https://root.cern.ch/download/cling/cling_2019-12-08_ubuntu18.tar.bz2 && tar jxf cling_2019-12-08_ubuntu18.tar.bz2 && \
    cd cling_2019-12-08_ubuntu18 && cp -r . /usr/. && cd ~ && rm -r pre && \
    cd /usr/share/cling/Jupyter/kernel && pip3 install -e . && \
    jupyter kernelspec install cling-cpp11 && jupyter kernelspec install cling-cpp14 && jupyter kernelspec install cling-cpp17 && jupyter kernelspec install cling-cpp1z && \
    cp /usr/share/cling/Jupyter/kernel/cling.ipynb /workdir && \
#NodeJS  && \
    npm install -g configurable-http-proxy && \
    npm install -g --unsafe-perm ijavascript && \
    npm install -g --unsafe-perm itypescript && \
    its --ts-hide-undefined --install=global && \
    ijsinstall --hide-undefined --install=global  && \
    npm cache clean --force && \
#clean up && \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*

ADD settings/jupyter_notebook_config.py /etc/jupyter/
ADD settings/jupyterhub_config.py /etc/jupyterhub/
COPY scripts /scripts

#RUN chmod -R 755 /scripts && /scripts/sys/create_user_nogroup.sh dave 2000

ENV M2_HOME=/usr/share/maven
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

#EXAMPLES

#RUN mkdir /root/examples && \
#	cd /root/examples && \
#        wget -O TensorFlow-Examples.zip https://github.com/aymericdamien/TensorFlow-Examples/archive/master.zip && \
#        unzip TensorFlow-Examples.zip && \
#        cd TensorFlow-Examples-master && \
#        cp -Rv notebooks/ /workdir/tensorflow/ 
        
EXPOSE 8000
