#!/bin/bash
git clone https://github.com/laurent22/rsync-time-backup ~/rsync-time-backup \
    && chmod +x ~/rsync-time-backup/rsync_tmbackup.sh
mkdir -p -- "/wrangler/backup-notebooks"
# Required by rsync-time-backup
touch "/wrangler/backup-notebooks/backup.marker"

(crontab -l ; echo \
     "0 */1 * * * ~/xsede-jetstream/vms/jupyter/backup-notebooks.sh") | crontab -
