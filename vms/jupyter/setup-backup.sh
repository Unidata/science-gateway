#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

git clone https://github.com/laurent22/rsync-time-backup /tmp/rsync-time-backup && \
    cp /tmp/rsync-time-backup/rsync_tmbackup.sh /usr/local/bin/

mkdir -p -- "/wrangler/backup-notebooks"

# Required by rsync-time-backup
touch "/wrangler/backup-notebooks/backup.marker"

(crontab -l ; echo \
     "0 0 * * * /usr/local/bin/rsync_tmbackup.sh --rsync-set-flags \"--recursive --numeric-ids --no-perms --itemize-changes\"  /notebooks /wrangler/backup-notebooks") | crontab -
