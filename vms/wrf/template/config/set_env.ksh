#!/bin/ksh

# WRF settings
########################################################################
export WPS_VERSION="4.3"
export WRF_VERSION="4.3"
export input_data="GFS" # Input data type: Used for VTable file extension
#export case_name=""

# UPP settings
########################################################################
# Set input format from model
export inFormat="netcdf"
export outFormat="grib2"

# Set domain lists
export domain_list="d01 d02"

# Set date/time information for each domain. Set the same if no difference.
export startdate_d01=START_DATE_UPP_D1 # YYYYMMddhh
export fhr_d01=00 # hh; Here, I assume you want to post process them all, so start at fhr 0
export lastfhr_d01=24 # hh
export incrementhr_d01=03

export startdate_d02=START_DATE_UPP_D2 # YYYYMMddhh
export fhr_d02=00 # hh; Here, I assume you want to post process them all, so start at fhr 0
export lastfhr_d02=24 # hh
export incrementhr_d02=03 # hh

# Python settings
#########################################################################
export init_time=2022082712
export fhr_beg=00
export fhr_end=24
export fhr_inc=03
