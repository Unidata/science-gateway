#! /bin/bash

##############
# Initialize this directory for use as the root directory of a containerized wrf
# project
##############

echo "
-----------------------------------------------
Starting wrf_proj_init.sh...
-----------------------------------------------"
echo ""

echo "
-----------------------------------------------
Checking for docker...
-----------------------------------------------"
echo ""

which docker || { echo "ERROR: docker not installed on this system. Please install docker before proceeding"; exit 1; }
echo ""

echo "
-----------------------------------------------
Checking for git
-----------------------------------------------"
echo ""

which git || { echo "ERROR: git not installed on this system. Please install git before proceeding"; exit 1; }
echo ""

function usage () {
cat <<USAGE
Usage:
./wrf_proj_init.sh \\\\
  -i|--input </path/to/input/data/dir> \\\\
  [ -g|--geog <low|high> ] \\\\
  [ -p|--proj-version <version> ] \\\\
  [ -r|--run-history <num-of-days> ] \\\\
  [ -n|--num-cpus <num-of-cpus> ]

Options:
  --input: absolute path to the input data directory that will be shared by all model runs 
  --geog <low|high> (default low): dictates whether the WPS_GEOG directory will 
    be the low or high resolution geog data 
  --proj-version (default latest): dictates the tag of the dtcenter docker 
    images used to run WRF 
      https://hub.docker.com/r/dtcenter/wps_wrf/tags 
      https://github.com/NCAR/container-dtc-nwp 
  --run-history (default 5): number of days before daily model runs are scoured 
  --num-cpus (default 1): number of CPUs on which to run WRF
USAGE
}

##############
# Parse input options
##############

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -i|--input)
            # Remove any trailing slashes from path names
            INPUT_DATA_DIR=$(echo $2 | sed -e "s/\/*$//g")
            if [[ ! -d "${INPUT_DATA_DIR}" ]];
            then
                echo "ERROR: the directory \"${INPUT_DATA_DIR}\" does not exist. Exiting..."
                usage
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
            usage
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
                usage
                exit 1
            fi
            RUN_HISTORY=$2
            ;;
        -n|--num-cpus)
            if [[ ! "$2" =~ ^[1-9]+$ ]];
            then
                echo "ERROR: num-cpus must be a positive integer. Exiting..."
                usage
                exit 1
            fi
            NUM_CPUS=$2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
    esac
    shift # past argument or value
done

##############
# Set default variables
##############

echo "
-----------------------------------------------
Checking input variables...
-----------------------------------------------"
echo ""

# Ensure the INPUT_DATA_DIR variable has been set
if [[ -z "${INPUT_DATA_DIR}" ]];
then
    echo "ERROR: An input data directory is a required argument. Exiting..."
    usage
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
        usage
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
echo "Input data dir: ${INPUT_DATA_DIR}"
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

echo "
-----------------------------------------------
Pulling dtcenter/wps_wrf:${PROJ_VERSION}
-----------------------------------------------"
echo ""

docker pull dtcenter/wps_wrf:${PROJ_VERSION} || { echo "Pull failed. Exiting..."; exit 1; }
echo ""

echo "
-----------------------------------------------
Pulling dtcenter/upp:${PROJ_VERSION}
-----------------------------------------------"
echo ""

docker pull dtcenter/upp:${PROJ_VERSION} || { echo "Pull failed. Exiting..."; exit 1; }
echo ""

##############
# Official DTC repo has all the scripts necessary to run WRF
##############

echo "
-----------------------------------------------
Cloning NCAR/container-dtc-nwp repository...
-----------------------------------------------"
echo ""
git clone https://github.com/NCAR/container-dtc-nwp ${PROJ_DIR}/container-dtc-nwp
echo ""

##############
# Science Gateway repo will eventually have the cron_scripts and template
# directories that are shared by all model runs
##############

echo "
-----------------------------------------------
Cloning unidata/science-gateway repository...
-----------------------------------------------"
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

echo "
-----------------------------------------------
Editing config files...
-----------------------------------------------"
echo ""

sed -i "s|export PROJ_DIR=|&${PROJ_DIR}|" ${PROJ_DIR}/cron_scripts/full_run.sh

sed -i "s|export PROJ_DIR=|&${PROJ_DIR}|" ${PROJ_DIR}/cron_scripts/set_env.sh
sed -i "s|export INPUT_DATA_DIR=|&${INPUT_DATA_DIR}|" ${PROJ_DIR}/cron_scripts/set_env.sh
sed -i "s|export PROJ_VERSION=|&${PROJ_VERSION}|" ${PROJ_DIR}/cron_scripts/set_env.sh
sed -i "s|export RUN_HISTORY=|&${RUN_HISTORY}|" ${PROJ_DIR}/cron_scripts/set_env.sh
sed -i "s|export NUM_CPUS=|&${NUM_CPUS}|" ${PROJ_DIR}/cron_scripts/set_env.sh

sed -i "s|GEOG_DATA_RES|${GEOG_DATA_RES}|g" ${PROJ_DIR}/output/template/config/namelist.wps

echo "Done"
echo ""

##############
# Create data directories
##############

mkdir -p ${PROJ_DIR}/data/model_data
cd ${PROJ_DIR}/data

##############
# Grab the WPS_GEOG files from MMM
##############

echo "
-----------------------------------------------
Downloading WPS_GEOG files from MMM...
-----------------------------------------------"
echo ""

curl https://www2.mmm.ucar.edu/wrf/src/wps_files/${GEOG} --output ${PROJ_DIR}/data/${GEOG}

# Unzip
tar xzf ${PROJ_DIR}/data/${GEOG}

# When unzipping the low res data, the resulting directory is named
# "WPS_GEOG_LOW_RES"; ensure our GEOG data is named "WPS_GEOG"
if [[ "$GEOG_DATA_RES" == "lowres" ]]
then
    mv ${PROJ_DIR}/data/WPS_GEOG_LOW_RES ${PROJ_DIR}/data/WPS_GEOG
fi

rm ${PROJ_DIR}/data/${GEOG}

cd ${PROJ_DIR}

cat <<MSG
-----------------------------------------------
!!! Begin additional user actions           !!!
-----------------------------------------------

For support, please contact support-gateway@unidata.ucar.edu

-----------------------------------------------
Set crontab
-----------------------------------------------
Edit your crontab with: crontab -e

Add the following line to run the model at the time specified and log output:

<min> <hr> <day-of-month> <month> <day-of-week> bash -l -c '${PROJ_DIR}/cron_scripts/full_run.sh'

NOTE: The cron job will run according to the system time, whose timezone is:
timedatectl status | grep "Time zone" | awk -F ": " '{print $2}')

Some versions of cron allow you to specify a time zone on which the cron
jobs will run. Check \"man 5 crontab\" to see if your version is compatible with
the CRON_TZ environment variable.

To make the cron job run according to a specific time zone, e.g. UTC, add
the following to the top of the cron tab:

CRON_TZ=\"<timezone>\"

Where <timezone> is one of the timezones listed when you run \"timedatectl list-timezones\"

-----------------------------------------------
Edit ${PROJ_DIR}/cron_scripts/set_env.sh:
-----------------------------------------------"

Edit the cron job environment file: ${PROJ_DIR}/cron_scripts/set_env.sh to
specify the start hour:min:sec of each model run for each day, as well as the
model run time. These can be changed whenever and will take effect the next time
the cron job runs

-----------------------------------------------
Edit WRF config files
-----------------------------------------------"

Edit WRF config files in ${PROJ_DIR}/output/template/config to your liking.

These can be changed whenever and will take effect the next time the cron job
runs.

Do NOT edit any variable values that are strings in capital letters, as these
will be handled by the cron job--e.g. in the namelist.input file. For example,
the following line from ${PROJ_DIR}/output/template/config should NOT be
changed:

\"run_days = RUN_DAYS,\"

-----------------------------------------------
!!! End additional user actions             !!!
-----------------------------------------------

For support, please contact support-gateway@unidata.ucar.edu

Happy WRF-ing! :)

MSG
