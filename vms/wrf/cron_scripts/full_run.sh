#! /bin/bash

# Set automatically when running wrf_proj_init.sh
export PROJ_DIR=

# Set environment for the day
# All necessary variables are exported, so they are inherited by any child
# shells (ie, when running other scripts)
source ${PROJ_DIR}/cron_scripts/set_env.sh

# Set to "1" if you want to debug shell variable issues...
DEBUG=1
if [[ DEBUG -e 1 ]];
then
    ${PROJ_DIR}/cron_scripts/print_env.sh
fi

# Remove "old" directories
# ${PROJ_DIR}/cron_scripts/scour.sh

# Re-link data, create directories, configure model for this run
${PROJ_DIR}/cron_scripts/configure_run.sh

# Run WPS
${PROJ_DIR}/cron_scripts/docker_run_wps.sh

# Run real
${PROJ_DIR}/cron_scripts/docker_run_real.sh

# Run WRF
${PROJ_DIR}/cron_scripts/docker_run_wrf.sh ${NUM_CPUS}

# Run UPP
${PROJ_DIR}/cron_scripts/docker_run_upp.sh
