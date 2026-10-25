FROM quay.io/jupyterhub/jupyterhub:latest

ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN pip install notebook jupyterlab

RUN pip3 install jupyter-c-kernel install_c_kernel

RUN printf "c = get_config()\n\nc.Authenticator.allow_all = True\n" \
    > /srv/jupyterhub/jupyterhub_config.py

EXPOSE 8000

CMD ["/scripts/sys/init.sh"]
