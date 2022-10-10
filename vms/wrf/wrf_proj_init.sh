#! /bin/bash

##############
# Initialize this directory for use as the root directory of a containerized wrf
# project
##############

echo ""
echo "-----------------------------------------------"
echo "Starting wrf_proj_init.sh..."
echo "-----------------------------------------------"
echo ""

# Ensure docker is installed
echo "-----------------------------------------------"
echo "Checking for docker..."
echo "-----------------------------------------------"
echo ""
which docker || { echo "ERROR: docker not installed on this system. Please install docker before proceeding"; exit 1; }
echo ""

# Ensure git is installed
echo "-----------------------------------------------"
echo "Checking for git"
echo "-----------------------------------------------"
echo ""
which git || { echo "ERROR: git not installed on this system. Please install git before proceeding"; exit 1; }

echo ""

USAGE="
Usage:
./wrf_proj_init.sh \n
-i|--input </path/to/input/data/dir> \n
[ -g|--geog <low|high> ] \n
[ -p|--proj-version <version> ] \n
[ -r|--run-history <num-of-days> ] \n
[ -n|--num-cpus <num-of-cpus> ] \n
\n
Options: \n
  --input: absolute path to the input data directory that will be shared by all model runs \n
  --geog <low|high> (default low): dictates whether the WPS_GEOG directory will \n
    be the low or high resolution geog data \n
  --proj-version (default latest): dictates the tag of the dtcenter docker \n
    images used to run WRF \n
       https://hub.docker.com/r/dtcenter/wps_wrf/tags \n
       https://github.com/NCAR/container-dtc-nwp \n
  --run-history (default 5): number of days before daily model runs are scoured \n
  --num-cpus (default 1): number of CPUs on which to run WRF
"

##############
# Parse input options
##############

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
	-i|--input)
            IDD_INPUT=$2
	    if [[ ! -d "${IDD_INPUT}" ]];
	    then
	        echo "ERROR: the directory \"${IDD_INPUT}\" does not exist. Exiting..."
		echo -e $USAGE
		exit 1
	    fi
            shift # past argument
	    ;;
        -g|--geog)
	    if [[ "$2" == "low" ]];
	    then
                GEOG="geog_low_res_mandatory.tar.gz";
		GEOG_DATA_RES="lowres"
	    elif [[ "$2" == "high" ]];
            then
		GEOG="geog_high_res_mandatory.tar.gz";
		GEOG_DATA_RES="default"
	    else
		echo "Incorrect option"
		echo "Allowed options: \"low\", \"high\""
		echo -e "$USAGE"
		exit 1
	    fi
            shift # past argument
            ;;
	-p|--proj-version)
	    PROJ_VERSION=$2
            shift # past argument
	    ;;
	-r|--run-history)
	    if [[ ! "$2" =~ ^[1-9]+[0-9]*$ ]];
	    then
                echo "ERROR: run-history must be a positive integer. Exiting..."
		echo -e "$USAGE"
		exit 1
	    fi
	    RUN_HISTORY=$2
	    ;;
	-n|--num-cpus)
	    if [[ ! "$2" =~ ^[1-9]+$ ]];
	    then
                echo "ERROR: num-cpus must be a positive integer. Exiting..."
		echo -e "$USAGE"
		exit 1
	    fi
	    NUM_CPUS=$2
	    ;;
        -h|--help)
            echo -e $USAGE
            exit 0
            ;;
    esac
    shift # past argument or value
done

##############
# Set default variables
##############

echo "-----------------------------------------------"
echo "Checking input variables..."
echo "-----------------------------------------------"
echo ""

# Ensure the IDD_INPUT variable has been set
if [[ -z "${IDD_INPUT}" ]];
then
    echo "ERROR: An input data directory is a required argument. Exiting..."
    echo -e $USAGE
    exit 1
fi

if [[ -z "${GEOG}" ]];
then
   echo "No --geog argument set -- defaulting to \"low\""
   export GEOG=${GEOG:-geog_low_res_mandatory.tar.gz}
   # For use in namelist.wps and geogrid
   export GEOG_DATA_RES=${GEOG_DATA_RES:-lowres}
fi

# Warn user about the dangers of using the default "latest" tag for a docker
# image and then set it as default with user confirmation
if [[ -z "${PROJ_VERSION}" ]];
then
    echo "WARNING: The --proj-version argument was not set; defaulting to the
    \"latest\" tag for downloading docker images"
    echo "WARNING: Not having an explicit project version makes it difficult to debug problems"
    read -p "Do you with to continue? (y/N) " CONTINUE
    if [[ "${CONTINUE}" != "y" ]];
    then
        echo "Exiting..."
	echo -e ${USAGE}
	exit 0
    fi
    PROJ_VERSION="latest"
fi

if [[ -z "${RUN_HISTORY}" ]];
then
    echo "No --run-history argument set -- defaulting to 5 days..."
    RUN_HISTORY=${RUN_HISTORY:-5}
fi

if [[ -z "${NUM_CPUS}" ]];
then
    echo "No --num-cpus argument set -- defaulting to 1 CPU..."
    NUM_CPUS=${NUM_CPUS:-1}
fi

echo "This directory will be initialized using the following parameters:"
echo "Input data dir: ${IDD_INPUT}"
echo "Geog data resolution: $(echo $GEOG | grep -o -e low -e high)"
echo "Project version: ${PROJ_VERSION}"
echo "Run history: ${RUN_HISTORY} days"
echo "Num of CPUs: ${NUM_CPUS}"
read -p "Continue? (y/n) " VARS_CHECK

[[ "${VARS_CHECK}" != "y" ]] && { echo "Exiting" ; exit 0 ; }

echo ""

##############
# Set environment variables
##############

export PROJ_DIR=$(pwd)

##############
# Download Docker images
##############

echo "-----------------------------------------------"
echo "Pulling dtcenter/wps_wrf:${PROJ_VERSION}"
echo "-----------------------------------------------"
echo ""
docker pull dtcenter/wps_wrf:${PROJ_VERSION} || { echo "Pull failed. Exiting..."; exit 1; }
echo ""
echo "-----------------------------------------------"
echo "Pulling dtcenter/upp:${PROJ_VERSION}"
echo "-----------------------------------------------"
echo ""
docker pull dtcenter/upp:${PROJ_VERSION} || { echo "Pull failed. Exiting..."; exit 1; }
echo ""

##############
# Official DTC repo has all the scripts necessary to run WRF
##############

echo "-----------------------------------------------"
echo "Cloning NCAR/container-dtc-nwp repository..."
echo "-----------------------------------------------"
echo ""
git clone https://github.com/NCAR/container-dtc-nwp ${PROJ_DIR}/container-dtc-nwp
echo ""

##############
# Science Gateway repo will eventually have the cron_scripts and template
# directories that are shared by all model runs
##############

echo "-----------------------------------------------"
echo "Cloning unidata/science-gateway repository..."
echo "-----------------------------------------------"
echo ""
# git clone https://github.com/Unidata/science-gateway ${PROJ_DIR}/science-gateway
# For dev purposes only v
git clone https://github.com/robertej09/science-gateway ${PROJ_DIR}/science-gateway
# For dev purposes only ^
echo ""

# For dev purposes only v
cd ${PROJ_DIR}/science-gateway
git checkout WRF
# For dev purposes only ^

mkdir -p ${PROJ_DIR}/output/
cp -r ${PROJ_DIR}/science-gateway/vms/wrf/cron_scripts ${PROJ_DIR} 
cp -r ${PROJ_DIR}/science-gateway/vms/wrf/template ${PROJ_DIR}/output/ 
mkdir ${PROJ_DIR}/output/template/{wpsprd,wrfprd,postprd}

# Delete the directory now that we've gotten what we need
cd ${PROJ_DIR}
rm -rf ${PROJ_DIR}/science-gateway

##############
# Edit env and config files
##############

echo "-----------------------------------------------"
echo "Editing config files..."
echo "-----------------------------------------------"
echo ""

# Set the PROJ_DIR variable in the cron_scripts/set_env.sh file
sed -i "s|export PROJ_DIR=|&${PROJ_DIR}|" ${PROJ_DIR}/cron_scripts/set_env.sh

# Set the PROJ_DIR variable in the cron_scripts/full_run.sh file
sed -i "s|export PROJ_DIR=|&${PROJ_DIR}|" ${PROJ_DIR}/cron_scripts/full_run.sh

# Set the IDD_INPUT variable in the cron_scripts/set_env.sh file
sed -i "s|export IDD_INPUT=|&${IDD_INPUT}|" ${PROJ_DIR}/cron_scripts/set_env.sh

# Set the appropriate WPS_GEOG resolution in namelist.wps
sed -i "s|GEOG_DATA_RES|${GEOG_DATA_RES}|g" ${PROJ_DIR}/output/template/config/namelist.wps

# Set the PROJ_VERSION variable in the cron_scripts/set_env.sh file
sed -i "s|export PROJ_VERSION=|&${PROJ_VERSION}|" ${PROJ_DIR}/cron_scripts/set_env.sh

# Set the RUN_HISTORY variable in the cron_scripts/set_env.sh file
sed -i "s|export RUN_HISTORY=|&${RUN_HISTORY}|" ${PROJ_DIR}/cron_scripts/set_env.sh

# Set the NUM_CPUS variable in the cron_scripts/set_env.sh file
sed -i "s|export NUM_CPUS=|&${NUM_CPUS}|" ${PROJ_DIR}/cron_scripts/set_env.sh

echo "Done"
echo ""

##############
# Create data directories
##############

mkdir -p ${PROJ_DIR}/data/model_data
cd ${PROJ_DIR}/data

# Grab the WPS_GEOG files from MMM
echo "-----------------------------------------------"
echo "Downloading WPS_GEOG files from MMM..."
echo "-----------------------------------------------"
echo ""
curl https://www2.mmm.ucar.edu/wrf/src/wps_files/${GEOG} --output ${PROJ_DIR}/data/${GEOG}
echo ""

# Unzip
tar xzf ${PROJ_DIR}/data/${GEOG}

# When unzipping the low res data, the resulting directory is named
# "WPS_GEOG_LOW_RES"; ensure our GEOG data is named "WPS_GEOG"
mv ${PROJ_DIR}/data/WPS_GEOG* ${PROJ_DIR}/data/WPS_GEOG

# Remove downloaded tar.gz file
rm ${PROJ_DIR}/data/${GEOG}

##############
# Prompt user to edit crontab
##############

echo ""
echo "-----------------------------------------------"
echo "!!! Additional user actions !!!"
echo "-----------------------------------------------"
echo ""

cd ${PROJ_DIR}

echo "Edit your crontab with: crontab -e"
echo "Add the following line to run the model at the time specified and log output:"
echo ""
echo "<min> <hr> <day-of-month> <month> <day-of-week> ${PROJ_DIR}/cron_scripts/full_run.sh 2>&1 >> ${PROJ_DIR}/cron_scripts/full_run.log"
echo ""
echo "NOTE: The cron job will run according to the system time, whose timezone is:
$(timedatectl status | grep "Time zone" | awk -F ": " '{print $2}')"
echo "To make the cron job run according to a specific time zone, e.g. UTC, add
the following to the top of the cron tab:"
echo ""
echo "CRON_TZ=\"<timezone>\""
echo ""
echo "Where <timezone> is one of the timezones listed when you run \"timedatectl list-timezones\""
echo ""

##############
# Prompt user to edit environment config file
##############

echo "Edit the cron job environment file: ${PROJ_DIR}/cron_scripts/set_env.sh to
specify the start hour:min:sec of each model run for each day, as well as the
model run time. These can be changed whenever and will take effect the next time
the cron job runs"
echo ""

##############
# Prompt user to edit WRF config files
##############

echo "Edit WRF config files in ${PROJ_DIR}/output/template/config to your liking"
echo "These can be changed whenever and will take effect the next time the cron
job runs"
echo "Do NOT edit any variable values that are strings in capital letters,
as these will be handled by the cron job--e.g. in the namelist.input file:"
echo "\"run_days = RUN_DAYS,\" should NOT be changed"

echo ""
echo "-----------------------------------------------"
echo "wrf_proj_init.sh complete!"
echo "-----------------------------------------------"
echo ""
