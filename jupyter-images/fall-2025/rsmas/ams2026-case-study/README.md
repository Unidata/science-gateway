- [AMS 2026 Case Study](#h-CF586FCF)
  - [Introduction](#h-0F8FBAA8)
  - [Relevant Files and Python Environment](#h-FEB28187)
  - [How to Run](#h-3BF74FF4)



<a id="h-CF586FCF"></a>

# AMS 2026 Case Study


<a id="h-0F8FBAA8"></a>

## Introduction

This case study builds on work by Professor Brian Mapes during the fall semester of 2025 for a Weather Analysis class at the University of Miami. Professor Mapes used a dedicated PyAOS JupyterHub environment provided by UCAR/NSF Unidata to develop a workflow in which global atmospheric wind fields from the [GFS 1-degree Best dataset](https://thredds.ucar.edu/thredds/catalog/grib/NCEP/GFS/Global_onedeg/catalog.html?dataset=grib/NCEP/GFS/Global_onedeg/Best), valid near the current time, are accessed and diagnostic quantities are computed programmatically in a Jupyter notebook using the [Windspharm](https://ajdawson.github.io/windspharm/) Python package. In particular, the workflow applies a [Helmholtz decomposition](https://en.wikipedia.org/wiki/Helmholtz_decomposition) to derive the velocity potential field at 200 hPa.

The resulting diagnostic fields are written to NetCDF and visualized using the cloud-hosted IDV desktop running within the same JupyterHub. Within the IDV, the velocity potential field is overlaid with contemporaneous global infrared satellite imagery, allowing direct visual comparison between large-scale divergence circulation patterns and convective cloud structures. Together, the notebook and IDV bundle illustrate a unified, browser-based workflow that integrates data access, dynamical diagnostics, and interactive visualization. The following section describes the two files involved for this case study.


<a id="h-FEB28187"></a>

## Relevant Files and Python Environment

Two files are included in this directory:

1.  `gfs_200hpa_helmholtz_decomposition.ipynb` This notebook demonstrates a workflow for computing a Helmholtz decomposition of global atmospheric wind fields. GFS wind data are accessed from Unidata's THREDDS catalog via OPeNDAP, subset by time and pressure level, and processed using Windspharm to compute streamfunction and velocity potential. The resulting diagnostic fields are written to NetCDF for subsequent visualization. The Python `environment.yml` required to run this notebook is found one directory level up.
2.  `gfs_200hpa_helmholtz_decomposition.xidv` This IDV bundle reads the NetCDF output produced by the notebook and visualizes the derived fields in combination with infrared satellite imagery corresponding to the same time step. The data are displayed using a Mollweide projection.


<a id="h-3BF74FF4"></a>

## How to Run

1.  Go to <https://jupyterhub.unidata.ucar.edu> and log in using CILogon.
2.  In JupyterLab, open a Terminal (File → New → Terminal) and run the following commands to download the required files:
    -   `wget https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/jupyter-images/fall-2025/rsmas/environment.yml`
    -   `wget https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/jupyter-images/fall-2025/rsmas/ams2026-case-study/gfs_200hpa_helmholtz_decomposition.ipynb`
    -   `wget https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/jupyter-images/fall-2025/rsmas/ams2026-case-study/gfs_200hpa_helmholtz_decomposition.xidv`
3.  In the same Terminal, create the conda environment:

    -   `mamba env create -f environment.yml`

    This step may take a few minutes to complete.
4.  Open `gfs_200hpa_helmholtz_decomposition.ipynb` in JupyterLab. From the top menu, select Kernel → Change Kernel, choose `rsmas25f`, and then run all cells in the notebook. This produces a NetCDF output file containing the results of the analysis.
5.  From the JupyterLab launcher, start the Unidata Desktop (IDV) and open the `gfs_200hpa_helmholtz_decomposition.xidv` bundle to visualize the results.
