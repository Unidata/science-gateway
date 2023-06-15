#!/bin/bash


######
# Add kernel metadata for a smooth experience at https://pyaos-workshop.unidata.ucar.edu
######

find .. -name \*ipynb | xargs -I {} bash -c "jq --indent 1 \
 '.metadata.kernelspec.display_name = \"Python [conda env:pyaos-ams-2023]\"' {} \
 > tmpfile; mv tmpfile {}"

find .. -name \*ipynb | xargs -I {} bash -c "jq --indent 1 \
 '.metadata.kernelspec.name = \"conda-env-pyaos-ams-2023-py\"' {} \
 > tmpfile; mv tmpfile {}"

