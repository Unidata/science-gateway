#! /bin/bash

##############################
# User editable fields
##############################

# This block is set automatically when running wrf_proj_init.sh
# See wrf_proj_init.sh for a description of these variables
export PROJ_DIR=
export IDD_INPUT=
export PROJ_VERSION=
export RUN_HISTORY=
export NUM_CPUS=

# Start times of model run for the outer domain
export START_HOUR_D1=12
export START_MINUTE_D1=00
export START_SECOND_D1=00

# Start times of model run for the nested domain
export START_HOUR_D2=12
export START_MINUTE_D2=00
export START_SECOND_D2=00

# Model run lengths
export RUN_DAYS=1
export RUN_HOURS=0
export RUN_MINUTES=0
export RUN_SECONDS=0

##############################
# User should not edit fields below
##############################

# Besides using the date for making the new directory, we will also use it to
# set various variables in the config files
export DATE=$(date +%Y-%m-%d)

# Start times for domain 1
export START_YEAR_D1=$(date --date="today" +%Y)
export START_MONTH_D1=$(date --date="today" +%m)
export START_DAY_D1=$(date --date="today" +%d)
export START_DATE_D1="${DATE} ${START_HOUR_D1}:${START_MINUTE_D1}:${START_SECOND_D1}"
export START_DATE_WPS_D1="${DATE}_${START_HOUR_D1}:${START_MINUTE_D1}:${START_SECOND_D1}"

# Start times for domain 2
export START_YEAR_D2=$(date --date="today" +%Y)
export START_MONTH_D2=$(date --date="today" +%m)
export START_DAY_D2=$(date --date="today" +%d)
export START_DATE_D2="${DATE} ${START_HOUR_D2}:${START_MINUTE_D2}:${START_SECOND_D2}"
export START_DATE_WPS_D2="${DATE}_${START_HOUR_D2}:${START_MINUTE_D2}:${START_SECOND_D2}"

# End times for domain 1
DATE_STRING_D1="${START_DATE_D1} ${RUN_DAYS} days ${RUN_HOURS} hours ${RUN_MINUTES} minutes ${RUN_SECONDS} seconds"
export END_YEAR_D1=$(date --date="${DATE_STRING_D1}" +%Y)
export END_MONTH_D1=$(date --date="${DATE_STRING_D1}" +%m)
export END_DAY_D1=$(date --date="${DATE_STRING_D1}" +%d)
export END_HOUR_D1=$(date --date="${DATE_STRING_D1}" +%H)
export END_MINUTE_D1=$(date --date="${DATE_STRING_D1}" +%M)
export END_SECOND_D1=$(date --date="${DATE_STRING_D1}" +%S)
export END_DATE_WPS_D1=$(date --date="${DATE_STRING_D1}" +%Y-%m-%d_%H:%M:%S)

# End times for domain 2
DATE_STRING_D2="${START_DATE_D2} ${RUN_DAYS} days ${RUN_HOURS} hours ${RUN_MINUTES} minutes ${RUN_SECONDS} seconds"
export END_YEAR_D2=$(date --date="${DATE_STRING_D2}" +%Y)
export END_MONTH_D2=$(date --date="${DATE_STRING_D2}" +%m)
export END_DAY_D2=$(date --date="${DATE_STRING_D2}" +%d)
export END_HOUR_D2=$(date --date="${DATE_STRING_D2}" +%H)
export END_MINUTE_D2=$(date --date="${DATE_STRING_D2}" +%M)
export END_SECOND_D2=$(date --date="${DATE_STRING_D2}" +%S)
export END_DATE_WPS_D2=$(date --date="${DATE_STRING_D2}" +%Y-%m-%d_%H:%M:%S)
