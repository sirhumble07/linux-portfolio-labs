#!/usr/bin/env bash

# Safe Bash settings
set -euo pipefail

# Timestamp for unique backup folders
TS="$(date +%F_%H%M%S)"

# Backup destination and Backups go into: /backup/YYYY-MM-DD_HHMMSS/
DEST="/backup/$TS"
LOG="/backup/logs/backup_$TS.log"

# Create the backup directory if it doesn't exist
sudo mkdir -p "$DEST"

# Backup /etc
sudo rsync -a /etc "$DEST/" | tee -a "$LOG"

# Backup /var/www if it exists
if [ -d "/var/www" ]; then
  sudo rsync -a /var/www "$DEST/" | tee -a "$LOG"
fi

# Final message with backup location
echo "Backup completed: $DEST" | tee -a "$LOG"

sudo chmod +x scripts/backup.sh