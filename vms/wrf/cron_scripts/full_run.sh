#! /bin/bash

set -x

echo -e "$(date +"[[ LOG: %F %T ]]") Starting WRF cron job...\n"

# Set automatically when running wrf_proj_init.sh
export PROJ_DIR=

# Set environment for the day
# All necessary variables are exported, so they are inherited by any child
# shells (ie, when running other scripts)
echo -e "$(date +"[[ LOG: %F %T ]]") Setting environment variables\n"
source ${PROJ_DIR}/cron_scripts/set_env.sh

# Set to "1" if you want to debug shell variable issues...
DEBUG=0
if [[ DEBUG -eq 1 ]];
then
    ${PROJ_DIR}/cron_scripts/print_env.sh
fi

# Remove "old" directories
# echo -e "$(date +"[[ LOG: %F %T ]]") Scouring old runs\n"
# ${PROJ_DIR}/cron_scripts/scour.sh

# Re-link data, create directories, configure model for this run
echo -e "$(date +"[[ LOG: %F %T ]]") Running configure_run.sh...\n"
${PROJ_DIR}/cron_scripts/configure_run.sh

# Run WPS
echo -e "$(date +"[[ LOG: %F %T ]]") Running docker_run_wps.sh...\n"
${PROJ_DIR}/cron_scripts/docker_run_wps.sh

if [[ $? -ne 0 ]];
then
    echo -e "$(date +"[[ ERROR: %F %T ]]") !!! CRON JOB FAILLED !!!"
    echo -e "$(date +"[[ ERROR: %F %T ]]") Cron job failed at docker_run_wps.sh. Printing shell environment for this cron job:\n"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    exit $?
fi

# Run real
echo -e "$(date +"[[ LOG: %F %T ]]") Running docker_run_real.sh...\n"
${PROJ_DIR}/cron_scripts/docker_run_real.sh

if [[ $? -ne 0 ]];
then
    echo -e "$(date +"[[ ERROR: %F %T ]]") !!! CRON JOB FAILLED !!!"
    echo -e "$(date +"[[ ERROR: %F %T ]]") Cron job failed at docker_run_real.sh. Printing shell environment for this cron job:\n"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    exit $?
fi

# Run WRF
echo -e "$(date +"[[ LOG: %F %T ]]") Running docker_run_wrf.sh...\n"
${PROJ_DIR}/cron_scripts/docker_run_wrf.sh ${NUM_CPUS}

if [[ $? -ne 0 ]];
then
    echo -e "$(date +"[[ ERROR: %F %T ]]") !!! CRON JOB FAILLED !!!"
    echo -e "$(date +"[[ ERROR: %F %T ]]") Cron job failed at docker_run_wrf.sh. Printing shell environment for this cron job:\n"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    exit $?
fi

# Run UPP
echo -e "$(date +"[[ LOG: %F %T ]]") Running docker_run_upp.sh...\n"
${PROJ_DIR}/cron_scripts/docker_run_upp.sh

if [[ $? -ne 0 ]];
then
    echo -e "$(date +"[[ ERROR: %F %T ]]") !!! CRON JOB FAILLED !!!"
    echo -e "$(date +"[[ ERROR: %F %T ]]") Cron job failed at docker_run_upp.sh. Printing shell environment for this cron job:\n"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    exit $?
fi
