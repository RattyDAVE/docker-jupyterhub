FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV M2_HOME=/usr/share/maven
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin:opt/conda/bin:~/.local/bin

#Note: This layer is needed to get PYTHON PIP and PYTHON SETUPTOOLS upgraded. For some reason this can't be combined and it causes and error when using pip3.
RUN mkdir -p /workdir && chmod 777 /workdir && \
    apt-get update -yqq && \ 
    apt-get install -yqq --no-install-recommends sudo curl git wget tzdata libjpeg-dev bzip2 && \
    apt-get install -yqq python3 python3-pip && \
    apt-get install -yqq lib32ncurses6 && \
    pip3 --no-cache-dir install --upgrade pip setuptools && \
    \
    #Julia && \
    echo "--------------------------------------" && \
    echo "----------- JULIA INSTALL ------------" && \
    echo "--------------------------------------" && \
    apt-get install -yqq julia && \
    \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -bfp /usr/local && \
    rm -rf /tmp/miniconda.sh && \
    conda install -y python=3 && \
    conda update conda && \
    conda clean --all --yes && \
    conda clean --force-pkgs-dirs -y

RUN conda install -c QuantStack -c conda-forge -c pytorch -c krinsman jupyterhub jupyterlab notebook nbgitpuller matplotlib tensorflow xeus-cling && \
    conda install -c pytorch pytorch torchvision torchaudio torchtext && \
    ##conda install -c conda-forge xeus-cling && \
    conda install -c conda-forge ipywidgets beakerx && \
    conda install -c conda-forge bash_kernel && \
    conda install -c conda-forge nodejs && \
    conda clean --all --yes && \
    conda clean --force-pkgs-dirs -y
#RUN conda install -c krinsman ijavascript && \
#    conda clean --all --yes
    
#RUN npm rebuild
#RUN npm install -g --unsafe-perm ijavascript && ijsinstall --hide-undefined --install=global

#RUN npm install -g --unsafe-perm itypescript && its --ts-hide-undefined --install=global

#NodeJS
#RUN conda install nodejs
#RUN npm install -g ijavascript
#RUN ijsinstall

#NodeJS
#RUN echo "--------------------------------------" && \
#    echo "----------- NodeJS -------------------" && \
#    echo "--------------------------------------" && \
#    npm install -g --unsafe-perm ijavascript && \
#    npm install -g --unsafe-perm itypescript && \
#    its --ts-hide-undefined --install=global && \
#    ijsinstall --hide-undefined --install=global && \
#    npm cache clean --force

#Julia
RUN echo "--------------------------------------" && \
    echo "----------- JULIA LINK TO JUPYTER ----" && \
    echo "--------------------------------------" && \
    julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("IJulia")'  && \
    cp -r /root/.local/share/jupyter/kernels/julia-* /usr/local/share/jupyter/kernels/  && \
    chmod -R +rx /usr/share/julia/  && \
    chmod -R +rx /usr/local/share/jupyter/kernels/julia-*/

#Add Extentions
#RUN jupyter labextension install jupyterlab-drawio
#RUN jupyter labextension install @wallneradam/run_all_buttons
#RUN jupyter labextension install jupyterlab-spreadsheet

ADD settings/jupyter_notebook_config.py /etc/jupyter/
ADD settings/jupyterhub_config.py /etc/jupyterhub/
ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN chmod -R 755 /scripts && \
    jupyter trust /etc/skel/StartHere.ipynb
    
EXPOSE 8000

CMD "/scripts/sys/init.sh"
