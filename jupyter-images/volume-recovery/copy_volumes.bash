#!/bin/bash
set -euo pipefail

SERVER_ID="89b8dcef-263b-4571-9c66-b74a900613a2"
DEVICE="/dev/sdb"
INPUT_FILE="volumes.txt"
# kubectl get pvc -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumeName}{"\n"}{end}'   | while read pvc vol; do       id=$(openstack volume show "$vol" -f value -c id);       echo -e "${id}\t${pvc}";     done
# ex
# <volume id> <pvc claim name, e.g., claim-jane>
DEST="./local"

while read -r VOL_ID NAME; do
    echo "=== Processing $VOL_ID ($NAME) ==="

    openstack server add volume "$SERVER_ID" "$VOL_ID"

    echo "Waiting for $DEVICE..."
    for i in {1..10}; do
        if lsblk | grep -q "$(basename $DEVICE)"; then
            break
        fi
        sleep 3
    done

    sudo mkdir -p "/data/$NAME"
    sudo mount -o ro "$DEVICE" "/data/$NAME"
    rsync -a /data/$NAME/ "$DEST/$NAME/" >/dev/null 2>&1 || true

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
