# Containerized WRF as a cron job

This project makes use of the Developmental Testbed Center's [Numerical Weather
Prediction
Containers](https://dtcenter.org/community-code/numerical-weather-prediction-nwp-containers)
project (see it on [GitHub](https://github.com/NCAR/container-dtc-nwp) to run
WRF as a cron job. The provided init script depends only on `docker`, `git`,
common tools such as `bash`, `sed`, `curl`, `tar`, and of course, `cron`.

## wrf\_proj\_init.sh

The init script's purpose is to download all necessary (`docker`) images and
files, set some settings used for running WRF as a cron job, create the
appropriate directory structure (see the section below), and provide
instructions for editing your `crontab`. Download and run the script by:

```shell
mkdir <wrf-dir> && cd <wrf-dir>
curl -O https://raw.githubusercontent.com/Unidata/science-gateway/master/vms/wrf/wrf_proj_init.sh
chmod u+x ./wrf_proj_init.sh
./wrf_proj_init.sh <args>
```

See the necessary and optional arguments by running `./wrf_proj_init.sh --help`.

After successfully running the init script, you will be prompted to further
configure the cron job and WRF run.

## Directory structure for input data

The scripts provided will attempt to link the GFS initialization data from the
path given to `wrf_proj_init.sh` via the `--input` flag. To ensure the correct
data is linked, the following directory structure is required of the GFS input
data:

`${INPUT_DATA_DIR}/YYYYMMDD/TTz/*.grib2`

The strings `YYYYMMDD` and `TTz` represent the date and model run time of the
GFS model run you wish to ingest from. For example, if you are run WRF on Feb.
12, 2023 starting at 12z, your input data must be found under:

`${INPUT_DATA_DIR}/20230212/12z/*.grib2`

## What the cron job will do

As per the init script's instructions, the cron job will execute
`cron_scripts/full_run.sh`.  This script calls other scripts which use the
configuration set in the initialization step to run WRF and produce output in a
newly formed subdirectory.

It is important to note that while the cron job will run according to the system
time zone (`timedatectl | grep "Time zone"`), the start and end dates the model
will run through will be with respect to UTC. For example, if your system
timezone is MDT (UTC -0600) and you wanted to run WRF 3 hours every day after
each GFS run, set your crontab as follows:

```shell
# Job runs at 0300, 0900, 1500, and 2100 MDT (2100Z, 0300Z, 0900Z, and 1500Z, respectively)
0 3,9,15,21 * * * /path/to/full_run.sh
```

Set the START\_HOUR variables in `cron\_scripts/set\_env.sh` to be 3 hours
before the (UTC) time the jobs run:

```shell
export START_HOUR_D1=$(date --utc --date="-3 hours" +%H)
export START_HOUR_D2=$(date --utc --date="-3 hours" +%H)
```

## Downloading Data

The cron job will *not* provide you with input data. You must provide that on
your own through some means. One way to do this by downloading it from NOAA's
[NOMADS](https://nomads.ncep.noaa.gov/) using `ftp`. An example script is found
(here)[./examples/fetch-ncep-gfs.sh].
