#! /bin/bash

# Example for downloading GFS model data from NCEP's ftp server
# See: https://www.nco.ncep.noaa.gov/pmb/products/gfs/ 

DATE="$(date +%Y%m%d)"
MODEL_RUN_START="00"

# RESOLUTION="0p25"
# RESOLUTION="0p50"
RESOLUTION="1p00"

FORECAST_HR="000"

URL="ftp://ftp.ncep.noaa.gov"
FILE_PATH="pub/data/nccf/com/gfs/prod/gfs.${DATE}/${MODEL_RUN_START}/atmos"
FILE="gfs.t${MODEL_RUN_START}z.pgrb2.${RESOLUTION}.f${FORECAST_HR}"

ftp -o $(pwd)/${FILE}.grib2 ${URL}/${FILE_PATH}/${FILE}
