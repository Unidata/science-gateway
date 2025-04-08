#!/bin/bash
set -e

umask 0002

USERNAME=${JOVYAN_USERNAME:-jovyan}
USER_ID=${JOVYAN_USER_ID:-1000}
GROUP_ID=${JOVYAN_GROUP_ID:-1000}

# Create jovyan user
groupadd -r ${USERNAME} -g ${GROUP_ID} && \
useradd -u ${USER_ID} -g ${USERNAME} -ms /bin/bash -c "JOVYAN user" ${USERNAME}

# Disable sudo/su
dnf -y remove sudo && rm -f /bin/su /usr/bin/su /usr/bin/sudo || true

# Drop privileges and launch VNC
exec gosu ${USERNAME} /usr/local/bin/launch-vnc.sh
