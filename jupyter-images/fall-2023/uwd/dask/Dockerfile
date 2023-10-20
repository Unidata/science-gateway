ARG BASE_CONTAINER=ghcr.io/dask/dask-gateway:2023.9.0
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

# Assuming that pip is already installed in the base container
RUN pip install --no-cache-dir \
    xarray \
    netCDF4 \
    h5netcdf \
    'lz4==4.3.2' \
    'cytoolz==0.12.2'
