FROM ghcr.io/astral-sh/uv:debian

ENV SHELL=/bin/bash
ENV SKYPILOT_DEV=1

WORKDIR /skycamp-tutorial

RUN uv venv -p 3.10

ENV PATH="/skycamp-tutorial/.venv/bin:${PATH}"

RUN echo "export PATH=\"/skycamp-tutorial/.venv/bin:${PATH}\"" >> /root/.bashrc

# Install tutorial dependencies
RUN uv pip install jupyter jupyterlab

# Install SkyPilot + dependencies
RUN uv pip install "skypilot[kubernetes,gcp,aws] @ git+https://github.com/skypilot-org/skypilot.git@v0.10.5"

RUN apt update -y && \
    apt install rsync nano vim curl jq -y && \
    rm -rf /var/lib/apt/lists/*

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY . /skycamp-tutorial

RUN jupyter lab --generate-config && \
    echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.trust_xheaders = True" >> ~/.jupyter/jupyter_notebook_config.py

# Use sky show-gpus to update the catalog, avoid random output in the notebook
CMD ["/bin/bash", "-c", \
     "jupyter lab --no-browser --ip '*' --allow-root --notebook-dir=/skycamp-tutorial \
          --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.base_url=$BASE_URL"]
