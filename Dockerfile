FROM sagemath/sagemath:9.0

EXPOSE 8888

USER root

# Install necessary tools
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
      ca-certificates \
      curl \
      git \
      gosu

# Install Node.js (for installing/configuring jupyterlab plugins)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y --no-install-recommends  \
      nodejs \
      build-essential

USER sage

# Install python modules in Sage's python
RUN sage -sh -c "pip install ipykernel" && \
    sage -sh -c "pip install jupyterlab" && \
    sage -sh -c "pip install --upgrade ipywidgets"

# Create directories
RUN mkdir /home/sage/config
RUN mkdir /home/sage/install
RUN mkdir /home/sage/host

# Copy default config
COPY jupyter_notebook_config.py /home/sage/install

USER root
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

# Volumes
VOLUME /home/sage/host
VOLUME /home/sage/config

ENTRYPOINT ["/entrypoint.sh"]
CMD sage -n jupyterlab  --conf=/home/sage/config/jupyter_notebook_config.py
