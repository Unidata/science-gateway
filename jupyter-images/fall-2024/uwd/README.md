- [JupyterHub Dask Cluster](#h-EA49F0AB)
  - [Introduction](#h-F0B09257)
  - [Dockerfiles](#h-6BC18085)
  - [apiTokens](#h-976A59DD)
  - [Notebooks](#h-CA62E6C3)
  - [Sizing the Cluster](#h-5D64640D)
    - [Warning](#h-1AD513D2)
  - [Removing Orphaned Dask Resources](#h-B80D999D)



<a id="h-EA49F0AB"></a>

# JupyterHub Dask Cluster


<a id="h-F0B09257"></a>

## Introduction

To build a JupyterHub Dask cluster on Jetstream2 follow Andrea Zonca's [instructions on the topic](https://www.zonca.dev/posts/2023-09-28-dask-gateway-jupyterhub).


<a id="h-6BC18085"></a>

## Dockerfiles

There are two Dockerfiles that need to be built for a Dask cluster instead of the usual one:

1.  The Dockerfile (co-located to this readme) that will represent the user environment. Note that the usual conda environments are absent. All packages are installed in the default environment via `pip` so the user never needs to switch environments and Dask will not get confused. The image built (e.g., `unidata/uwd-fall-2023:2023Oct27_161125_25a339bb`) from this Dockerfile will be pushed out to DockerHub and referenced in the usual `secrets.yaml` file and **also** `dask_gateway/config_jupyterhub.yaml`.
2.  A second Dockerfile (see Dask directory) is for Dask workers. This Dockerfile is much smaller, but does need to contain some of the same packages as the user environment. During execution of the notebook, it will sometimes complain about library version mismatches or discrepancies. It is best to resolve these by building Docker images with consistent package versions. The image built (e.g., `unidata/dask-gateway:2023.9.0`) from this Dockerfile will be pushed out to DockerHub and referenced in `dask_gateway/config_dask-gateway.yaml`. For example,

```yaml
c.Backend.cluster_options = Options(
    Integer("worker_cores", 2, min=1, max=4, label="Worker Cores"),
    Float("worker_memory", 4, min=1, max=8, label="Worker Memory (GiB)"),
    String("image", default="unidata/dask-gateway:2023.9.0", label="Image")
```


<a id="h-976A59DD"></a>

## apiTokens

Ensure the `apiToken` matches between `config_dask-gateway.yaml` and `config_jupyterhub.yaml`.


<a id="h-CA62E6C3"></a>

## Notebooks

There are a couple of notebooks that can be used as Dask case studies: `Dask.ipynb` and `wrf.ipynb`. Both notebooks fetch data from the UCAR RDA THREDDS server.

`Dask.ipynb` discusses the use of Xarray and Dask for handling large geospatial datasets, specifically ERA5 potential vorticity data. It covers how to optimize data chunking strategies for efficient calculations and introduces Dask's distributed computing capabilities to speed up operations across multiple cores. Some of the data can be fetched via FTP at adhara.aos.wisc.edu under `pub/zanowski/ERA5/`. See the `ERA5_data_fetcher.ipynb` notebook.

`wrf.ipynb` uses Dask and Xarray to analyze and visualize wind speed data from the WRF model. The notebook walks through setting up a Dask cluster, and then delves into reading and processing the WRF data, including unstaggering grids and calculating wind speeds.


<a id="h-5D64640D"></a>

## Sizing the Cluster

In order to properly size the cluster via `cluster.tfvars`, you need to take into account a few variables:

-   The number of students that will be accessing the cluster.
-   CPU and memory limits for their standard environments.
-   CPU and memory limits for Dask workers. See `config_dask-gateway.yaml` and also what may be defined in the notebook via `gateway.cluster_options()`.
-   How many Dask workers will actually be launched (scaled).

Taking all of that into account will allow you to calculate the the CPU and memory requirements for the entire cluster which will then allow you to determine the number of VMs you will need.


<a id="h-1AD513D2"></a>

### Warning

You are about to launch a large cluster that is going to generate many Docker image downloads from docker.io which has rate limits. [Take measures to limit the number of image pulls from docker.io](file:///Users/chastang/git/science-gateway/.org/openstack/readme.md).


<a id="h-B80D999D"></a>

## Removing Orphaned Dask Resources

Sometimes when working with Dask clusters, users will forget to shutdown the cluster perhaps because the notebook had trouble finishing to completion. In that case, you may wish to clean up orphaned resources. Note that the command below will clean up all dask clusters so use with caution in order not to interrupt a users work.

```sh
kubectl delete pod -n jhub $(kubectl get pods -n jhub | grep dask-worker | awk '{print $1}')
kubectl delete pod -n jhub $(kubectl get pods -n jhub | grep dask-scheduler | awk '{print $1}')
```
