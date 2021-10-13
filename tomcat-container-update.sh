#!/usr/bin/env bash

set -e

source ~/.bash_profile

BASE_IMAGE="8.5-jdk8-openjdk"

JDK8="8.5"
JDK11="8.5-jdk11-openjdk"

TOMCAT_JDK8="unidata/tomcat-docker:$JDK8"
TOMCAT_JDK11="unidata/tomcat-docker:$JDK11"
TOMCAT_LATEST="unidata/tomcat-docker:latest"

TDS_FOUR_CURRENT="4.6.17"
TDS_FIVE_CURRENT="5.0"

TDS_FOUR="unidata/thredds-docker:$TDS_FOUR_CURRENT"
TDS_FIVE="unidata/thredds-docker:$TDS_FIVE_CURRENT"
TDS_LATEST="unidata/thredds-docker:latest"

RAMADDA_CURRENT="2.2"

RAMADDA="unidata/ramadda-docker:$RAMADDA_CURRENT"
RAMADDA_LATEST="unidata/ramadda-docker:latest"

cd ~/tomcat-docker

CURRENT=$(docker image ls  --all | grep $BASE_IMAGE | awk '{print $3}')

docker pull tomcat:$BASE_IMAGE

LATEST=$(docker image ls  --all | grep $BASE_IMAGE | awk '{print $3}')

if [ "$CURRENT" != "$LATEST" ];then

    docker system prune -a -f  > /dev/null 2>&1

    cd ~/tomcat-docker && git fetch -a && git checkout $JDK8 && \
        docker build -t $TOMCAT_JDK8 . && docker push $TOMCAT_JDK8 \
        > /dev/null 2>&1

    cd ~/tomcat-docker && git fetch -a && git checkout $JDK11  \
        && docker build -t $TOMCAT_JDK11 . && docker push $TOMCAT_JDK11 \
        > /dev/null 2>&1

    cd ~/tomcat-docker && git fetch -a && git checkout $JDK8 && \
        docker build -t $TOMCAT_LATEST . && docker push $TOMCAT_LATEST \
        > /dev/null 2>&1

    cd ~/thredds-docker && git fetch -a && git checkout $TDS_FOUR_CURRENT && \
        docker build -t $TDS_FOUR . && docker push $TDS_FOUR > /dev/null 2>&1

    cd ~/thredds-docker && git fetch -a && git checkout $TDS_FIVE_CURRENT && \
        docker build -t $TDS_FIVE . && docker push $TDS_FIVE > /dev/null 2>&1

    cd ~/thredds-docker && git fetch -a && git checkout $TDS_FOUR_CURRENT && \
        docker build -t $TDS_LATEST . && docker push $TDS_LATEST \
        > /dev/null 2>&1

    cd ~/ramadda-docker && git fetch -a && git checkout $RAMADDA_CURRENT && \
        docker build -t $RAMADDA . && docker push $RAMADDA > /dev/null 2>&1

    cd ~/ramadda-docker && git fetch -a && git checkout $RAMADDA_CURRENT  && \
        docker build -t $RAMADDA_LATEST . && docker push $RAMADDA_LATEST \
        > /dev/null 2>&1
fi
