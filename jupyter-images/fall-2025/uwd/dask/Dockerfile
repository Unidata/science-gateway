# Steps to build the Docker docker.io/library/dask-gateway-server:2023.9.0 image:
#  git clone https://github.com/dask/dask-gateway.git
#  cd dask-gateway/dask-gateway
#  git checkout 2024.1.0
#  docker build -t dask-gateway:2024.1.0  .
ARG BASE_CONTAINER=docker.io/library/dask-gateway:2024.1.0
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

# Assuming that pip is already installed in the base container
RUN pip install --no-cache-dir \
    xarray \
    netCDF4 \
    h5netcdf \
    'lz4==4.3.3'

