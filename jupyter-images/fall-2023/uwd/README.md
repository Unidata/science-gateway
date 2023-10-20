- [JupyterHub Dask Cluster](#h-EA49F0AB)
  - [Introduction](#h-F0B09257)
  - [Dockerfiles](#h-6BC18085)
  - [Notebooks](#h-CA62E6C3)



<a id="h-EA49F0AB"></a>

# JupyterHub Dask Cluster


<a id="h-F0B09257"></a>

## Introduction

To build a JupyterHub Dask cluster on Jetstream2 follow Andrea Zonca's [instructions on the topic](https://www.zonca.dev/posts/2023-09-28-dask-gateway-jupyterhub).


<a id="h-6BC18085"></a>

## Dockerfiles

There are two Dockerfiles that need to be built for a Dask cluster instead of the usual one:

1.  The Dockerfile (co-located to this readme) that will represent the user environment. Note that the usual conda environments are absent. All packages are installed in the default environment via `pip` so the user never needs to switch environments and Dask will not get confused. The image built (e.g., `unidata/uwd-fall-2023:2023Oct27_161125_25a339bb`) from this Dockerfile will be pushed out to DockerHub and referenced in the usual `secrets.yaml` file and **also** `dask_gateway/config_jupyterhub.yaml`.
2.  A second Dockerfile (see Dask directory) is for Dask workers. This Dockerfile is much smaller, but does need to contain some of the same packages as the user environment. During execution of the notebook, it will sometimes complain about library version mismatches or discrepancies. It is best to resolve these by building Docker images with consistent package versions. The image built (e.g., `unidata/dask-gateway:2023.9.0c`) from this Dockerfile will be pushed out to DockerHub and referenced in `dask_gateway/config_dask-gateway.yaml`. For example,

```yaml
c.Backend.cluster_options = Options(
    Integer("worker_cores", 2, min=1, max=4, label="Worker Cores"),
    Float("worker_memory", 4, min=1, max=8, label="Worker Memory (GiB)"),
    String("image", default="unidata/dask-gateway:2023.9.0c", label="Image")
```


<a id="h-CA62E6C3"></a>

## Notebooks

There are a couple of notebooks that can be used as Dask case studies: `Dask.ipynb` and `wrf.ipynb`. Both notebooks fetch data from the UCAR RDA THREDDS server.

`Dask.ipynb` discusses the use of Xarray and Dask for handling large geospatial datasets, specifically ERA5 potential vorticity data. It covers how to optimize data chunking strategies for efficient calculations and introduces Dask's distributed computing capabilities to speed up operations across multiple cores. Some of the data can be fetched via FTP at adhara.aos.wisc.edu under `pub/zanowski/ERA5/`.

`wrf.ipynb` uses Dask and Xarray to analyze and visualize wind speed data from the WRF model. The notebook walks through setting up a Dask cluster, and then delves into reading and processing the WRF data, including unstaggering grids and calculating wind speeds.
