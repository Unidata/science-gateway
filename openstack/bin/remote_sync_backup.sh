#!/usr/bin/env bash

# Usage: script.sh VM_USER VM_HOST DESTINATION_PATH
# Backs up directories from a remote VM to a local destination.

# Exit on any error
set -e

# Check if sufficient arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 VM_USER VM_HOST DESTINATION_PATH"
    exit 1
fi

# Command line arguments
VM_USER="$1"
VM_HOST="$2"
DESTINATION_PATH="$3"

# Define source paths to be captured from VM
SOURCE_PATHS=("/var/log" "/root" "/home" "/etc")

# Retrieve the remote hostname from the remote host
REMOTE_HOSTNAME=$(ssh "$VM_USER@$VM_HOST" "hostname")

# Destination path - local, incorporating the name of the remote host
BACKUP_DIR="${DESTINATION_PATH}/${REMOTE_HOSTNAME}_backup"

# Create the destination directory if it doesn't exist
mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }

# Function to perform rsync operation
sync_files() {
    local source="$1"
    local destination="$2"

    # Rsync command explanation:
    # - rsync: Initiates the rsync command for file synchronization.
    # -a (archive): Preserves file structure and attributes (like permissions,
    # timestamps).
    # -z (compress): Compresses file data during transfer.
    # -h (human-readable): Outputs in a readable format.
    # -e "ssh": Specifies SSH as the remote shell
    # --rsync-path="sudo rsync": Runs rsync with sudo on the remote host, for
    # accessing files requiring root permissions.
    # -R use relative path names e.g., ./var/log/ not ./log/

    rsync -azhe "ssh " --quiet --rsync-path="sudo rsync" -R \
      "$VM_USER@$VM_HOST:$source" "$destination" > /dev/null 2>&1
}

# Main script execution
echo "Starting rsync operations: $(date)"
for path in "${SOURCE_PATHS[@]}"; do
    echo "Syncing $path from $VM_HOST"
    sync_files "$path" "$BACKUP_DIR" || true
done
echo "Rsync operations completed: $(date)"

# Change ownership of the files in the destination path to the current user
CURRENT_USER=$(id -un)
chmod -R u+rw "$BACKUP_DIR" || { echo "Chmod failed"; exit 1; }
chown -R "$CURRENT_USER" "$BACKUP_DIR" || { echo "Chown failed"; exit 1; }

# Create a tar.gz archive of the backup directory
ARCHIVE_FILE="${BACKUP_DIR}.tar.gz"
tar -czf "$ARCHIVE_FILE" -C "$DESTINATION_PATH" "$(basename "$BACKUP_DIR")" || \
    { echo "Tar and gzip failed"; exit 1; }

echo "Backup directory compressed to $ARCHIVE_FILE"

# Check if the archive file exists and is not empty
if [ -f "$ARCHIVE_FILE" ] && [ -s "$ARCHIVE_FILE" ]; then
    rm -rf "$BACKUP_DIR"
    echo "Backup directory deleted."
else
    echo "Error: Archive file not found or empty. Backup directory not deleted."
    exit 1
fi

echo "All done!"
