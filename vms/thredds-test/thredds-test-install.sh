#!/bin/bash

if [ ! -w "/data" ]; then
    echo "/data not writeable by current user $USER"
    exit 1
fi

../idd-archiver/idd-archiver-install.sh

../thredds/thredds-install.sh

# overwrite with customizations
cp ./etc/* ~/etc/
