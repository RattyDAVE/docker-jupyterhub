FROM jupyterhub/jupyterhub

#ADD settings/jupyter_notebook_config.py /etc/jupyter/
#ADD settings/jupyterhub_config.py /etc/jupyterhub/
ADD StartHere.ipynb /etc/skel
COPY scripts /scripts

RUN pip install notebook jupyterlab

RUN echo -e 'c = get_config() \n\nc.Authenticator.allow_all = True' > /srv/jupyterhub/jupyterhub_config.py

EXPOSE 8000

CMD "/scripts/sys/init.sh"
