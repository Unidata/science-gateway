#! /bin/bash

docker run --rm -it -e LOCAL_USER_ID=`id -u $USER` \
-v ${PROJ_DIR}/container-dtc-nwp/components/scripts/common:/home/scripts/common \
-v ${RUN_DIR}/wrfprd:/home/wrfprd \
-v ${RUN_DIR}/postprd:/home/postprd \
-v ${RUN_DIR}/config:/home/scripts/case \
--name run-dtc-nwp-upp dtcenter/upp:${PROJ_VERSION} /home/scripts/common/run_upp.ksh
