# JupyterHub Configuration for AMS 2023 LROSE Workshop

A few notes on this configuration:

- `environment.yml` can be found here and is not fetched from some external source.
- The LROSE team required that various command line utilities be installed so you will find those referenced inside the `Dockerfile`.
- `secrets.yaml` contains the JupyterHub configuration with the exception of
  - secret or unique identifiers
  - user names
  - admins
  - docker image tags

Copy `Acknowledgements.ipynb`, required for the Docker build, from the parent directory to this directory. For some reason, Docker builds do not let you copy files from parent directories.
