#!/bin/bash
set -euo pipefail

SERVER_ID="89b8dcef-263b-4571-9c66-b74a900613a2"
DEVICE="/dev/sdb"
INPUT_FILE="target.txt"
# kubectl get pvc -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumeName}{"\n"}{end}'   | while read pvc vol; do       id=$(openstack volume show "$vol" -f value -c id);       echo -e "${id}\t${pvc}";     done
# ex
# <volume id> <pvc claim name, e.g., claim-jane>
SRC="./local"   # where we're *grabbing* data from

JH_UID=1000
JH_GID=100

while read -r VOL_ID NAME; do
    echo "=== Processing $VOL_ID ($NAME) ==="

    if [ ! -d "$SRC/$NAME" ]; then
        echo "Source directory $SRC/$NAME not found; skipping $NAME."
        continue
    fi

    openstack server add volume "$SERVER_ID" "$VOL_ID"

    echo "Waiting for $DEVICE..."
    for i in {1..10}; do
        if lsblk | grep -q "$(basename "$DEVICE")"; then
            break
        fi
        sleep 3
    done

    sudo mkdir -p "/data/$NAME"
    sudo mount "$DEVICE" "/data/$NAME"

    sudo chown "$JH_UID:$JH_GID" "/data/$NAME"
    sudo chmod 2775 "/data/$NAME"

    rsync -rltD --delete \
          --no-owner --no-group --no-perms \
          --exclude 'lost+found' \
          "$SRC/$NAME/" "/data/$NAME/"

    sudo chown -R "$JH_UID:$JH_GID" "/data/$NAME"
    if [ -d "/data/$NAME/lost+found" ]; then
        sudo chown --no-dereference "$(stat -c '%u:%g' /data/$NAME/lost+found)" "/data/$NAME/lost+found" || true
    fi

    sudo find "/data/$NAME" -mindepth 1 -type d ! -name 'lost+found' -exec chmod 2775 {} +

    sudo find "/data/$NAME" -type f -exec chmod 664 {} +

    if [ -f "/data/$NAME/.ICEauthority" ]; then
        sudo chmod 600 "/data/$NAME/.ICEauthority"
    fi
    if [ -f "/data/$NAME/.bash_history" ]; then
        sudo chmod 660 "/data/$NAME/.bash_history"
    fi
    if [ -d "/data/$NAME/.ssh" ]; then
        sudo chmod 700 "/data/$NAME/.ssh"
        sudo find "/data/$NAME/.ssh" -type f -exec chmod 600 {} +
    fi
    if [ -d "/data/$NAME/.gnupg" ]; then
        sudo chmod 2770 "/data/$NAME/.gnupg"
        sudo find "/data/$NAME/.gnupg" -type f -exec chmod 660 {} +
    fi
    if [ -d "/data/$NAME/.dbus" ]; then
        sudo chmod 2770 "/data/$NAME/.dbus"
        sudo find "/data/$NAME/.dbus" -type f -exec chmod 660 {} +
    fi

    sync
    sudo umount "$DEVICE"

    for i in {1..5}; do
        if ! mount | grep -q "$DEVICE"; then
            break
        fi
        sleep 2
    done

    openstack server remove volume "$SERVER_ID" "$VOL_ID"

    echo "=== Done $VOL_ID ($NAME) ==="
done < "$INPUT_FILE"
