#!/bin/bash

docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/data/WPS_GEOG:/data/WPS_GEOG \
-v ${PROJ_DIR}/data:/data \
-v ${IDD_INPUT}:${IDD_INPUT} \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${PROJ_DIR}/${DATE}/wrfprd:/home/wrfprd \
-v ${PROJ_DIR}/${DATE}/wpsprd:/home/wpsprd \
-v ${PROJ_DIR}/${DATE}/config:/home/scripts/case \
--name run-dtc-nwp-wps dtcenter/wps_wrf:${PROJ_VERSION} \
/home/scripts/common/run_wps.ksh
