# JupyterHub Configuration for AMS 2023 Student Python Workshop

A few notes on this configuration:

- This Docker build is mostly self-contained with the exception of the `environment.yml` which is fetched from the [Unidata/pyaos-ams-2023](http://github.com/Unidata/pyaos-ams-2023) repository.
- `secrets.yaml` contains the JupyterHub configuration with the exception of
  - secret or unique identifiers
  - user names
  - admins
  - docker image tags

The `env.sh` is a convenience script for altering notebook metadata so the user is dropped into the correct conda environment when opening the notebook. You will need `jq` installed.

Copy `Acknowledgements.ipynb`, required for the Docker build, from the parent directory to this directory. For some reason, Docker builds do not let you copy files from parent directories.
