#! /bin/bash

##############################
# User editable fields
##############################

# This block is set automatically when running wrf_proj_init.sh
# See wrf_proj_init.sh for a description of these variables
echo "PROJ_DIR: " ${PROJ_DIR}
echo "IDD_INPUT: " ${IDD_INPUT}
echo "PROJ_VERSION: " ${PROJ_VERSION}
echo "RUN_HISTORY: " ${RUN_HISTORY}
echo "NUM_CPUS: " ${NUM_CPUS}

# Start times of model run for the outer domain
echo "START_HOUR_D1: " ${START_HOUR_D1}
echo "START_MINUTE_D1: " ${START_MINUTE_D1}
echo "START_SECOND_D1: " ${START_SECOND_D1}

# Start times of model run for the nested domain
echo "START_HOUR_D2: " ${START_HOUR_D2}
echo "START_MINUTE_D2: " ${START_MINUTE_D2}
echo "START_SECOND_D2: " ${START_SECOND_D2}

# Model run lengths
echo "RUN_DAYS: " ${RUN_DAYS}
echo "RUN_HOURS: " ${RUN_HOURS}
echo "RUN_MINUTES: " ${RUN_MINUTES}
echo "RUN_SECONDS: " ${RUN_SECONDS}

##############################
# User should not edit fields below
##############################

# Besides using the date for making the new directory, we will also use it to
# set various variables in the config files
echo "DATE: " ${DATE}

# Start times for domain 1
echo "START_YEAR_D1: " ${START_YEAR_D1}
echo "START_MONTH_D1: " ${START_MONTH_D1}
echo "START_DAY_D1: " ${START_DAY_D1}
echo "START_DATE_D1: " ${START_DATE_D1}
echo "START_DATE_WPS_D1: " ${START_DATE_WPS_D1}

# Start times for domain 2
echo "START_YEAR_D2: " ${START_YEAR_D2}
echo "START_MONTH_D2: " ${START_MONTH_D2}
echo "START_DAY_D2: " ${START_DAY_D2}
echo "START_DATE_D2: " ${START_DATE_D2}
echo "START_DATE_WPS_D2: " ${START_DATE_WPS_D2}

# End times for domain 1
echo "END_YEAR_D1: " ${END_YEAR_D1}
echo "END_MONTH_D1: " ${END_MONTH_D1}
echo "END_DAY_D1: " ${END_DAY_D1}
echo "END_HOUR_D1: " ${END_HOUR_D1}
echo "END_MINUTE_D1: " ${END_MINUTE_D1}
echo "END_SECOND_D1: " ${END_SECOND_D1}
echo "END_DATE_WPS_D1: " ${END_DATE_WPS_D1}

# End times for domain 2
echo "END_YEAR_D2: " ${END_YEAR_D2}
echo "END_MONTH_D2: " ${END_MONTH_D2}
echo "END_DAY_D2: " ${END_DAY_D2}
echo "END_HOUR_D2: " ${END_HOUR_D2}
echo "END_MINUTE_D2: " ${END_MINUTE_D2}
echo "END_SECOND_D2: " ${END_SECOND_D2}
echo "END_DATE_WPS_D2: " ${END_DATE_WPS_D2}
