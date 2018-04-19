#!/bin/bash

RSYNC_FLAGS="\"--numeric-ids --no-perms --itemize-changes\""

SRC=/notebooks
DST=/wrangler/backup-notebooks

# Using echo to preserve quotes in variable expansion. Maybe there is a better
# way to do it.
if [[ -d ${DST} ]];then
    echo ~/rsync-time-backup/rsync_tmbackup.sh --rsync-set-flags ${RSYNC_FLAGS} \
                                          ${SRC} ${DST} | sh;
fi
