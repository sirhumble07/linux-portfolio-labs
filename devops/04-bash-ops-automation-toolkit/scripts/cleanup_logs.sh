#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/log"
DAYS=14

echo "Cleaning logs older than $DAYS days in $LOG_DIR"

find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -print -delete

echo "Cleanup complete."
