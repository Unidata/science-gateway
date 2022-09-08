#! /bin/bash

echo ""
echo "-----------------------------------------------"
echo "Starting WRF cron job..."
echo "-----------------------------------------------"
echo ""

# Set automatically when running wrf_proj_init.sh
export PROJ_DIR=

# Set environment for the day
# All necessary variables are exported, so they are inherited by any child
# shells (ie, when running other scripts)
echo "-----------------------------------------------"
echo "Setting environment variables"
echo "-----------------------------------------------"
echo ""
source ${PROJ_DIR}/cron_scripts/set_env.sh

# Set to "1" if you want to debug shell variable issues...
DEBUG=0
if [[ DEBUG -eq 1 ]];
then
    ${PROJ_DIR}/cron_scripts/print_env.sh
fi

# Remove "old" directories
# echo "-----------------------------------------------"
# echo "Scouring old runs"
# echo "-----------------------------------------------"
# echo ""
# ${PROJ_DIR}/cron_scripts/scour.sh

# Re-link data, create directories, configure model for this run
echo "-----------------------------------------------"
echo "Running configure_run.sh..."
echo "-----------------------------------------------"
echo ""
${PROJ_DIR}/cron_scripts/configure_run.sh

# Run WPS
echo "-----------------------------------------------"
echo "Running docker_run_wps.sh..."
echo "-----------------------------------------------"
echo ""
${PROJ_DIR}/cron_scripts/docker_run_wps.sh

if [[ $? -ne 0 ]];
then
    echo "-----------------------------------------------"
    echo "!!! CRON JOB FAILLED !!!"
    echo "-----------------------------------------------"
    echo "Cron job failed at docker_run_wps.sh. Printing shell environment for this cron job:"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    echo ""
    exit $?
fi

# Run real
echo "-----------------------------------------------"
echo "Running docker_run_real.sh..."
echo "-----------------------------------------------"
echo ""
${PROJ_DIR}/cron_scripts/docker_run_real.sh

if [[ $? -ne 0 ]];
then
    echo "-----------------------------------------------"
    echo "!!! CRON JOB FAILLED !!!"
    echo "-----------------------------------------------"
    echo "Cron job failed at docker_run_real.sh. Printing shell environment for this cron job:"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    echo ""
    exit $?
fi

# Run WRF
echo "-----------------------------------------------"
echo "Running docker_run_wrf.sh..."
echo "-----------------------------------------------"
echo ""
${PROJ_DIR}/cron_scripts/docker_run_wrf.sh ${NUM_CPUS}

if [[ $? -ne 0 ]];
then
    echo "-----------------------------------------------"
    echo "!!! CRON JOB FAILLED !!!"
    echo "-----------------------------------------------"
    echo "Cron job failed at docker_run_wrf.sh. Printing shell environment for this cron job:"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    echo ""
    exit $?
fi

# Run UPP
echo "-----------------------------------------------"
echo "Running docker_run_upp.sh..."
echo "-----------------------------------------------"
echo ""
${PROJ_DIR}/cron_scripts/docker_run_upp.sh

if [[ $? -ne 0 ]];
then
    echo "-----------------------------------------------"
    echo "!!! CRON JOB FAILLED !!!"
    echo "-----------------------------------------------"
    echo "Cron job failed at docker_run_upp.sh. Printing shell environment for this cron job:"
    ${PROJ_DIR}/cron_scripts/print_env.sh
    echo ""
    exit $?
fi
