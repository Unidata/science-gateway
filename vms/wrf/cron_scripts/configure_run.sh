#! /bin/bash

set -x

# Create new directory for the day's run
cp -r ${PROJ_DIR}/output/template ${RUN_DIR}

# Re-link data (symbolically)
ln -s ${IDD_INPUT}/*.grib2 ${PROJ_DIR}/data/model_data

#######################
# Edit set_env.ksh
#######################
START_DATE_UPP_D1="${START_YEAR_D1}${START_MONTH_D1}${START_DAY_D1}${START_HOUR_D1}"
sed -i "s/START_DATE_UPP_D1/${START_DATE_UPP_D1}/" ${RUN_DIR}/config/set_env.ksh

START_DATE_UPP_D2="${START_YEAR_D2}${START_MONTH_D2}${START_DAY_D2}${START_HOUR_D2}"
sed -i "s/START_DATE_UPP_D2/${START_DATE_UPP_D2}/" ${RUN_DIR}/config/set_env.ksh

#######################
# Edit namelist.wps
#######################

sed -i "s/START_DATE_WPS_D1/${START_DATE_WPS_D1}/" ${RUN_DIR}/config/namelist.wps
sed -i "s/START_DATE_WPS_D2/${START_DATE_WPS_D2}/" ${RUN_DIR}/config/namelist.wps

sed -i "s/END_DATE_WPS_D1/${END_DATE_WPS_D1}/" ${RUN_DIR}/config/namelist.wps
sed -i "s/END_DATE_WPS_D2/${END_DATE_WPS_D2}/" ${RUN_DIR}/config/namelist.wps

#######################
# Edit namelist.input
#######################

# Run time
sed -i "s/RUN_DAYS/${RUN_DAYS}/" ${RUN_DIR}/config/namelist.input
sed -i "s/RUN_HOURS/${RUN_HOURS}/" ${RUN_DIR}/config/namelist.input
sed -i "s/RUN_MINUTES/${RUN_MINUTES}/" ${RUN_DIR}/config/namelist.input
sed -i "s/RUN_SECONDS/${RUN_SECONDS}/" ${RUN_DIR}/config/namelist.input

# Start date: Domain 1
sed -i "s/START_YEAR_D1/${START_YEAR_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_MONTH_D1/${START_MONTH_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_DAY_D1/${START_DAY_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_HOUR_D1/${START_HOUR_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_MINUTE_D1/${START_MINUTE_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_SECOND_D1/${START_SECOND_D1}/" ${RUN_DIR}/config/namelist.input

# Start date: Domain 2
sed -i "s/START_YEAR_D2/${START_YEAR_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_MONTH_D2/${START_MONTH_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_DAY_D2/${START_DAY_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_HOUR_D2/${START_HOUR_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_MINUTE_D2/${START_MINUTE_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/START_SECOND_D2/${START_SECOND_D2}/" ${RUN_DIR}/config/namelist.input

# End date: Domain 1
sed -i "s/END_YEAR_D1/${END_YEAR_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_MONTH_D1/${END_MONTH_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_DAY_D1/${END_DAY_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_HOUR_D1/${END_HOUR_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_MINUTE_D1/${END_MINUTE_D1}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_SECOND_D1/${END_SECOND_D1}/" ${RUN_DIR}/config/namelist.input

# End date: Domain 2
sed -i "s/END_YEAR_D2/${END_YEAR_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_MONTH_D2/${END_MONTH_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_DAY_D2/${END_DAY_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_HOUR_D2/${END_HOUR_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_MINUTE_D2/${END_MINUTE_D2}/" ${RUN_DIR}/config/namelist.input
sed -i "s/END_SECOND_D2/${END_SECOND_D2}/" ${RUN_DIR}/config/namelist.input
