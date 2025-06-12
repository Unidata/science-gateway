# Saswata Nandi: Indian Institute of Technology

JupyterHub server for Saswata Nandi of the Indian Institute of Technology
Bombay, department of civil engineering for "hydro-climatic forecasting over
Indian river basins."

eSupport Ticket ID: BQE-975328

## Environment

Conda environment has the following packages/libraries installed

- DATA-SPEC:
    - intake
    - intake-xarray
    - siphon
    - pystack
- IO: 
    - cfgrib
    - eccodes
    - geopandas
    - iris
    - metpy
    - netcdf4
    - rasterio
    - rioxarray
    - shapely
    - xarray
    - zarr
- ANALYZE:
    - climpred
    - gdal
    - geemap
    - keras
    - pytorch
    - regionmask
    - sciket
    - scikit-learn
    - xagg
    - xesmf
    - salem
- MODELLING:
    - climetlab
    - raven
    - summa
    - landlab
- VISUALIZATION:
    - cartopy
    - cmaps
    - matplotlib

## Special Notes

- The ["CliMetLab"](https://climetlab.readthedocs.io/en/latest/installing.html)
package doesn't yet have a conda package available, so we must enter our conda
environment and install through pip.
- The "sciket" package doesn't exist -- assumed to be "scikit-learn"
- The "pystack" package could refer to the python debugger, double check to
  ensure this is what they want
- The "summa" package couldn't be resolved along with the rest of the
  environment, so it will be installed manually on the system (not within conda)
  - It can be found in /summa
  - Reference Dockerfile for a list of steps taken to install
