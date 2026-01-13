- [AMS 2026 Case Study](#h-CF586FCF)
  - [Introduction](#h-0F8FBAA8)
  - [Relevant Files and Python Environment](#h-FEB28187)



<a id="h-CF586FCF"></a>

# AMS 2026 Case Study


<a id="h-0F8FBAA8"></a>

## Introduction

This case study builds on work by Professor Brian Mapes done during the fall semester of 2025 for an Weather Analysis class at the University of Miami. Brian used a dedicated PyAOS JupyterHub environment provided by UCAR/NSF Unidata to develop a workflow in which atmospheric data are accessed and diagnostic fields are computed programmatically in a Jupyter notebook. The resulting NetCDF files are then visualized using the cloud-hosted IDV desktop running within the same JupyterHub environment. Together, the notebook and IDV bundle illustrate a unified workflow that integrates data access, diagnostic computation, and interactive visualization in a browser-based setting. The following sections describe the two files involved.


<a id="h-FEB28187"></a>

## Relevant Files and Python Environment

Two files are included in this directory:

1.  `gfs_200hpa_helmholtz_decomposition.ipynb` This notebook demonstrates a workflow for computing a [Helmholtz decomposition](https://en.wikipedia.org/wiki/Helmholtz_decomposition) of global atmospheric wind fields. GFS wind data are accessed from Unidata’s THREDDS catalog via OPeNDAP, subset by time and pressure level, and processed using the [Windspharm](https://ajdawson.github.io/windspharm/) Python package to compute streamfunction and velocity potential. The resulting diagnostic fields are written to NetCDF for subsequent visualization. The Python `environment.yml` required to run this notebook is found one directory level up.

```yaml
name: rsmas25f
channels:
 - conda-forge
dependencies:
  # Required by JupyterLab
  - 'python<3.13'
  - nb_conda_kernels
  - ipykernel
  # User requested packages
  - cartopy
  - earthaccess
  - gif
  - h5netcdf
  - hdf5
  - ipywidgets
  - iris
  - matplotlib
  - metpy
  - netcdf4
  - numpy
  - pandas
  - pip
  - siphon
  - windspharm
  - xarray
  - pip:
      - mseplots-pkg
```

1.  `gfs_200hpa_helmholtz_decomposition.xidv` This IDV bundle reads the NetCDF output produced by the notebook and visualizes the derived fields in combination with infrared satellite imagery corresponding to the same time step. The data are displayed using a Mollweide projection.
