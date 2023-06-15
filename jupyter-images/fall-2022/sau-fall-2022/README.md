# SAU

JupyterLab image for Keith Maull's (of SAU) data mining class. Based off of
Jupyter's
[scipy-notebook](https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile)
image.

## Packages

### Explicitly Installed Packages

The base environment (see the next section) is cloned and these additional
packages are installed.

See [environment.yml](./environment.yml). Some of these may be installed as
dependencies of the implicitly installed packages, but we make their
installation explicit.

- scikit-learn
- numpy
- scipy
- matplotlib
- openpyxl

### Implicitly Installed Packages

Some packages are inherited from the base container(s):

[base-notebook](https://github.com/jupyter/docker-stacks/blob/main/base-notebook/Dockerfile)
-->
[minimal-notebook](https://github.com/jupyter/docker-stacks/blob/main/minimal-notebook/Dockerfile)
-->
[scipy-notebook](https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile)

Packages inherited from the base container(s):

  - mamba
  - notebook
  - jupyterhub
  - jupyterlab
  - altair
  - beautifulsoup4
  - bokeh
  - bottleneck
  - cloudpickle
  - conda-forge::blas==openblas
  - cython
  - dask
  - dill
  - h5py
  - ipympl
  - ipywidgets
  - matplotlib-base
  - numba
  - numexpr
  - pandas
  - patsy
  - protobuf
  - pytables
  - scikit-image
  - scikit-learn
  - scipy
  - seaborn
  - sqlalchemy
  - statsmodels
  - sympy
  - widgetsnbextension
  - xlrd
