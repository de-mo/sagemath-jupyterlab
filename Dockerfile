FROM sagemath/sagemath:9.1

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
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y --no-install-recommends  \
      nodejs \
      build-essential

# Empty apt-get list
RUN rm -rf /var/lib/apt/lists/*

USER sage

# Update to avoid incompatibility error (only for 9.1)
RUN sage -sh -c "pip install --upgrade jupyter-core"
# Install python modules in Sage's python
RUN sage -sh -c "pip install ipykernel" && \
    sage -sh -c "pip install jupyterlab" && \
    sage -sh -c "pip install --upgrade ipywidgets"

# Create directories
RUN mkdir /home/sage/config && \
    mkdir /home/sage/install && \
    mkdir /home/sage/host

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
