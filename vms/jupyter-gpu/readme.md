- [Launching a GPU-enabled JupyterHub on Jetstream2](#h-CA72713B)
  - [Introduction](#h-F4C02739)
    - [Approaches that did not work](#h-5899570E)
  - [Launching a GPU Jetstream2 VM](#h-F0B34A78)
  - [Building the Docker Container](#h-EBEA458C)
  - [Configuration of the jupyterhub\_config.py](#h-DFD13D52)
  - [Launch with docker-compose](#h-27F68492)
  - [Test to make sure the GPU is actually running](#h-3FF12410)



<a id="h-CA72713B"></a>

# Launching a GPU-enabled JupyterHub on Jetstream2


<a id="h-F4C02739"></a>

## Introduction

Launching a GPU-enabled JupyterHub with Tensorflow on Jetstream2 can be done without much effort with the help of Docker, a JupyterHub configuration and GitHub OAuth. The strategy employed here is to take a stock Tensorflow Docker container and install JupyterHub on top of that.


<a id="h-5899570E"></a>

### Approaches that did not work

-   I did not have any success installing CUDA and Tensorflow related software on the base VM. There were too many errors related to shared object (`.so`) files missing.
-   [GPU Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#gpu-enabled-notebooks). I believe the [OpenStack layer for this technology is missing though may be available for commercial cloud providers](https://z2jh.jupyter.org/en/stable/jupyterhub/customizing/user-resources.html#set-user-gpu-guarantees-limits).
-   Efforts built on top or with The Littlest JupyterHub.


<a id="h-F0B34A78"></a>

## Launching a GPU Jetstream2 VM

Choose an Ubuntu VM. Rocky does not appear to be quite there yet as far as GPU drivers are concerned. To ensure JupyterHub is happy, make sure ports `8000`, `8001`, `8081` are open on the VM.


<a id="h-EBEA458C"></a>

## Building the Docker Container

A few notes on the `unidata/jupyterhub-gpu` container:

-   The base image is `tensorflow/tensorflow:latest-devel-gpu`.
-   Everything beyond that base image is essentially [the official JupyterHub Docker image](https://github.com/jupyterhub/jupyterhub/blob/main/Dockerfile) with the exception of a few libraries such as `tensorflow-gpu`.

To build the image you'll need to be in the jupyterhub git repo because the `Dockerfile` requires that the jupyterhub source be copied into the image:

```sh
git clone https://github.com/jupyterhub/jupyterhub
cp Dockerfile jupyterhub/
cd jupyterhub
docker build -t unidata/jupyterhub-gpu .
```


<a id="h-DFD13D52"></a>

## Configuration of the jupyterhub\_config.py

The JupyterHub configuration is essentially a default JupyterHub configuration with the following changes:

-   `c.JupyterHub.port = 443`
-   GitHub Oauth

You'll also need a [Letsencrypt certificate](https://github.com/wmnnd/nginx-certbot).


<a id="h-27F68492"></a>

## Launch with docker-compose

```yaml
version: '3'

services:
  jupyterhub:
    image: unidata/jupyterhub-gpu:latest
    container_name: tensor-gpu
    volumes:
      - ./server:/srv/jupyterhub
    ports:
      - "80:80"
      - "443:443"
      - "8000:8000"
      - "8001:8001"
      - "8081:8081"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```


<a id="h-3FF12410"></a>

## Test to make sure the GPU is actually running

[Example code can be found here](https://www.tensorflow.org/guide/gpu).

Also, take a look at the `gpu.ipynb` notebook included here. That notebook should run to completion though you may see some warnings and informational diagnostics.
