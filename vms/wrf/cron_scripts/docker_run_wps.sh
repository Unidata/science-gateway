#!/bin/bash

set -x

docker run --rm -t -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/data/WPS_GEOG:/data/WPS_GEOG \
-v ${PROJ_DIR}/data:/data \
-v ${INPUT_DATA_DIR}:${INPUT_DATA_DIR} \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${RUN_DIR}/wrfprd:/home/wrfprd \
-v ${RUN_DIR}/wpsprd:/home/wpsprd \
-v ${RUN_DIR}/config:/home/scripts/case \
--name run-dtc-nwp-wps dtcenter/wps_wrf:${PROJ_VERSION} \
/home/scripts/common/run_wps.ksh
