#!/bin/bash

# Variables
WORLD_PATH="/home/server/minecraft/world"
BACKUP_HOST="192.168.0.101"
BACKUP_USER="meowcat"
BACKUP_DIR="/home/meowcat/backups/minecraft-world"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
TAR_FILE="/tmp/minecraft_world_$TIMESTAMP.tar.gz"

# Stop auto-saving in Minecraft
tmux send-keys -t minecraft "save-off" C-m
tmux send-keys -t minecraft "save-all" C-m

echo "Stopped saving for backup!"
# Give the server a few seconds to flush
sleep 5

echo "Packing world into tarball..."
tar -czf "$TAR_FILE" -C "$(dirname "$WORLD_PATH")" "$(basename "$WORLD_PATH")"

# Re-enable auto-saving
tmux send-keys -t minecraft "save-on" C-m
echo "Saving has been enabled"

# Ensure backup directory exists on Pi-hole
ssh "$BACKUP_USER@$BACKUP_HOST" "mkdir -p $BACKUP_DIR"

echo "Sending tarball to Pi-hole..."
scp "$TAR_FILE" "$BACKUP_USER@$BACKUP_HOST:$BACKUP_DIR/"

# Remove temporary tarball locally
rm "$TAR_FILE"

echo "Backup complete!!"
