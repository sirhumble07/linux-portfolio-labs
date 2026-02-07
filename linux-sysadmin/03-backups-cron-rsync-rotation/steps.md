# Steps — Automated Backups: cron + rsync + Logging + Restore Test

## 1) Prepare

```bash
sudo apt update
sudo apt -y install rsync
sudo mkdir -p /backup/logs


### 1.1 Create Directory Structure

```bash
sudo mkdir -p /backup/{daily,weekly,monthly}
sudo mkdir -p /backup/logs
sudo mkdir -p /source_data
```

### 1.2 Set Permissions

```bash
sudo chmod 750 /backup
sudo chmod 750 /source_data
```

### 1.3 Create Test Data

```bash
sudo mkdir -p /source_data/{documents,configs,databases}
echo "Sample document $(date)" | sudo tee /source_data/documents/doc1.txt
echo "Sample config $(date)" | sudo tee /source_data/configs/app.conf
dd if=/dev/urandom of=/source_data/databases/testdb.dat bs=1M count=10
```

## Step 2: Install Required Tools

### 2.1 Install Rsync

```bash
sudo apt install rsync -y  # Ubuntu/Debian
# OR
sudo yum install rsync -y  # RHEL/CentOS
```

### 2.2 Verify Installation

```bash
rsync --version
which rsync
```

## Step 3: Create Basic Backup Script

### 3.1 Create Backup Script

```bash
sudo nano /usr/local/bin/backup.sh
```

Add the following content:

```bash
#!/bin/bash

# Backup Script with Rsync and Rotation
# Author: System Administrator
# Date: $(date +%Y-%m-%d)

# Configuration
SOURCE_DIR="/source_data"
BACKUP_BASE="/backup"
LOG_FILE="/backup/logs/backup_$(date +%Y%m%d_%H%M%S).log"
RETENTION_DAILY=7
RETENTION_WEEKLY=4
RETENTION_MONTHLY=6

# Timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATE=$(date +%Y-%m-%d)

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Start backup
log_message "=== Backup Started ==="
log_message "Source: $SOURCE_DIR"
log_message "Destination: $BACKUP_BASE"

# Daily Backup
DAILY_BACKUP="$BACKUP_BASE/daily/backup_$TIMESTAMP"
log_message "Creating daily backup: $DAILY_BACKUP"

rsync -avz --delete \
    --exclude='*.tmp' \
    --exclude='*.log' \
    --log-file="$LOG_FILE" \
    "$SOURCE_DIR/" "$DAILY_BACKUP/"

if [ $? -eq 0 ]; then
    log_message "Daily backup completed successfully"
else
    log_message "ERROR: Daily backup failed"
    exit 1
fi

# Create backup metadata
echo "Backup Date: $DATE" > "$DAILY_BACKUP/backup_info.txt"
echo "Backup Time: $(date '+%H:%M:%S')" >> "$DAILY_BACKUP/backup_info.txt"
echo "Source: $SOURCE_DIR" >> "$DAILY_BACKUP/backup_info.txt"
du -sh "$DAILY_BACKUP" >> "$DAILY_BACKUP/backup_info.txt"

# Rotation - Daily backups (keep last 7 days)
log_message "Rotating daily backups (keeping last $RETENTION_DAILY days)"
find "$BACKUP_BASE/daily" -maxdepth 1 -type d -name "backup_*" -mtime +$RETENTION_DAILY -exec rm -rf {} \;

# Weekly backup (every Sunday)
if [ $(date +%u) -eq 7 ]; then
    WEEKLY_BACKUP="$BACKUP_BASE/weekly/backup_$TIMESTAMP"
    log_message "Creating weekly backup: $WEEKLY_BACKUP"
    cp -al "$DAILY_BACKUP" "$WEEKLY_BACKUP"
    
    # Rotate weekly backups
    log_message "Rotating weekly backups (keeping last $RETENTION_WEEKLY weeks)"
    find "$BACKUP_BASE/weekly" -maxdepth 1 -type d -name "backup_*" -mtime +$((RETENTION_WEEKLY * 7)) -exec rm -rf {} \;
fi

# Monthly backup (first day of month)
if [ $(date +%d) -eq 01 ]; then
    MONTHLY_BACKUP="$BACKUP_BASE/monthly/backup_$TIMESTAMP"
    log_message "Creating monthly backup: $MONTHLY_BACKUP"
    cp -al "$DAILY_BACKUP" "$MONTHLY_BACKUP"
    
    # Rotate monthly backups
    log_message "Rotating monthly backups (keeping last $RETENTION_MONTHLY months)"
    find "$BACKUP_BASE/monthly" -maxdepth 1 -type d -name "backup_*" -mtime +$((RETENTION_MONTHLY * 30)) -exec rm -rf {} \;
fi

# Backup statistics
BACKUP_SIZE=$(du -sh "$DAILY_BACKUP" | cut -f1)
log_message "Backup size: $BACKUP_SIZE"

# Disk space check
DISK_USAGE=$(df -h "$BACKUP_BASE" | tail -1 | awk '{print $5}' | sed 's/%//')
log_message "Backup partition usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 85 ]; then
    log_message "WARNING: Backup partition usage above 85%"
fi

log_message "=== Backup Completed ==="
```

### 3.2 Make Script Executable

```bash
sudo chmod +x /usr/local/bin/backup.sh
```

### 3.3 Test Backup Script

```bash
sudo /usr/local/bin/backup.sh
```

### 3.4 Verify Backup Created

```bash
ls -lh /backup/daily/
cat /backup/logs/backup_*.log
```

## Step 4: Configure Cron Jobs

### 4.1 View Current Cron Jobs

```bash
crontab -l
sudo crontab -l
```

### 4.2 Edit Root Crontab

```bash
sudo crontab -e
```

Add the following entries:

```cron
# Daily backup at 2 AM
0 2 * * * /usr/local/bin/backup.sh >> /backup/logs/cron.log 2>&1

# Weekly system update check (Sunday at 3 AM)
0 3 * * 0 /usr/bin/apt update >> /var/log/apt-update-check.log 2>&1

# Monthly disk usage report (1st of month at 6 AM)
0 6 1 * * df -h > /var/log/disk-usage-$(date +\%Y\%m).txt

# Clean old logs every day at midnight
0 0 * * * find /backup/logs -name "*.log" -mtime +30 -delete
```

### 4.3 Verify Cron Service

```bash
sudo systemctl status cron  # Ubuntu/Debian
# OR
sudo systemctl status crond  # RHEL/CentOS
```

### 4.4 Check Cron Logs

```bash
sudo tail -f /var/log/syslog | grep CRON  # Ubuntu/Debian
# OR
sudo tail -f /var/log/cron  # RHEL/CentOS
```

## Step 5: Advanced Rsync Techniques

### 5.1 Incremental Backup with Hard Links

```bash
# Create incremental backup script
sudo nano /usr/local/bin/incremental_backup.sh
```

Add:

```bash
#!/bin/bash

BACKUP_DIR="/backup/incremental"
LATEST_LINK="$BACKUP_DIR/latest"
NEW_BACKUP="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

# Perform incremental backup
rsync -avz --delete \
    --link-dest="$LATEST_LINK" \
    /source_data/ "$NEW_BACKUP/"

# Update latest link
rm -f "$LATEST_LINK"
ln -s "$NEW_BACKUP" "$LATEST_LINK"

echo "Incremental backup completed: $NEW_BACKUP"
```

### 5.2 Make Executable and Test

```bash
sudo chmod +x /usr/local/bin/incremental_backup.sh
sudo /usr/local/bin/incremental_backup.sh
```

### 5.3 Remote Backup with Rsync over SSH

```bash
# Example remote backup (update with your details)
rsync -avz -e "ssh -p 22" \
    --progress \
    /source_data/ \
    user@remote-server:/remote/backup/location/
```

## Step 6: Configure Log Rotation

### 6.1 Create Custom Logrotate Configuration

```bash
sudo nano /etc/logrotate.d/custom-backups
```

Add:

```/backup/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        echo "Logs rotated on $(date)" >> /backup/logs/rotation.log
    endscript
}
```

### 6.2 Test Logrotate Configuration

```bash
sudo logrotate -d /etc/logrotate.d/custom-backups  # Dry run
sudo logrotate -f /etc/logrotate.d/custom-backups  # Force rotation
```

### 6.3 Verify Rotation

```bash
ls -lh /backup/logs/
```

## Step 7: Create Restore Script

### 7.1 Create Restore Script

```bash
sudo nano /usr/local/bin/restore.sh
```

Add:

```bash
#!/bin/bash

# Restore Script
# Usage: ./restore.sh [backup_directory] [restore_location]

if [ $# -ne 2 ]; then
    echo "Usage: $0 <backup_directory> <restore_location>"
    echo "Example: $0 /backup/daily/backup_20260206_020000 /restore"
    exit 1
fi

BACKUP_DIR="$1"
RESTORE_DIR="$2"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

echo "=== Restore Operation ==="
echo "Source: $BACKUP_DIR"
echo "Destination: $RESTORE_DIR"
echo ""
read -p "Continue with restore? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

mkdir -p "$RESTORE_DIR"

rsync -avz --progress "$BACKUP_DIR/" "$RESTORE_DIR/"

if [ $? -eq 0 ]; then
    echo "Restore completed successfully"
    ls -lh "$RESTORE_DIR"
else
    echo "ERROR: Restore failed"
    exit 1
fi
```

### 7.2 Make Executable

```bash
sudo chmod +x /usr/local/bin/restore.sh
```

### 7.3 Test Restore

```bash
# Find a backup to restore
BACKUP_TO_RESTORE=$(ls -d /backup/daily/backup_* | head -1)
echo "Restoring from: $BACKUP_TO_RESTORE"

# Perform restore
sudo /usr/local/bin/restore.sh "$BACKUP_TO_RESTORE" /tmp/restore_test
```

### 7.4 Verify Restored Data

```bash
ls -lh /tmp/restore_test
diff -r /source_data /tmp/restore_test
```

## Step 8: Monitoring and Notifications

### 8.1 Create Monitoring Script

```bash
sudo nano /usr/local/bin/backup_monitor.sh
```

Add:

```bash
#!/bin/bash

# Check if backup ran today
TODAY=$(date +%Y%m%d)
LATEST_BACKUP=$(ls -t /backup/daily/ | head -1)

if [[ $LATEST_BACKUP == *"$TODAY"* ]]; then
    echo "✓ Backup completed today: $LATEST_BACKUP"
else
    echo "✗ WARNING: No backup found for today!"
    # Send email notification (configure mail server first)
    # echo "Backup failed on $(date)" | mail -s "Backup Alert" admin@example.com
fi

# Check backup size
BACKUP_SIZE=$(du -sh /backup/daily/$LATEST_BACKUP 2>/dev/null | cut -f1)
echo "Latest backup size: $BACKUP_SIZE"

# Check disk space
df -h /backup
```

### 8.2 Make Executable

```bash
sudo chmod +x /usr/local/bin/backup_monitor.sh
```

### 8.3 Add to Crontab for Daily Check

```bash
sudo crontab -e
```

Add:

```cron
# Monitor backups daily at 8 AM
0 8 * * * /usr/local/bin/backup_monitor.sh >> /backup/logs/monitor.log 2>&1
```

## Step 9: Compressed Archive Backups

### 9.1 Create Tar Archive Backup

```bash
sudo tar -czf /backup/archive/backup_$(date +%Y%m%d).tar.gz /source_data
```

### 9.2 Create Archive Script

```bash
sudo nano /usr/local/bin/archive_backup.sh
```

Add:

```bash
#!/bin/bash

ARCHIVE_DIR="/backup/archive"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"

mkdir -p "$ARCHIVE_DIR"

tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" /source_data 2>/dev/null

echo "Archive created: $ARCHIVE_NAME"
ls -lh "$ARCHIVE_DIR/$ARCHIVE_NAME"
```

### 9.3 Make Executable and Test

```bash
sudo chmod +x /usr/local/bin/archive_backup.sh
sudo /usr/local/bin/archive_backup.sh
```

## Step 10: Documentation and Validation

### 10.1 List All Cron Jobs

```bash
sudo crontab -l
```

### 10.2 Check Backup Status

```bash
# List all backups
find /backup -type d -name "backup_*" | sort

# Show backup sizes
du -sh /backup/daily/*
du -sh /backup/weekly/*
du -sh /backup/monthly/*
```

### 10.3 Review Logs

```bash
tail -50 /backup/logs/backup_*.log
tail -50 /backup/logs/cron.log
```

### 10.4 Test Disaster Recovery

```bash
# Simulate data loss
sudo rm -rf /tmp/test_recovery
sudo mkdir /tmp/test_recovery

# Restore from latest backup
LATEST=$(ls -td /backup/daily/backup_* | head -1)
sudo rsync -av "$LATEST/" /tmp/test_recovery/

# Verify
ls -lh /tmp/test_recovery
```

## Troubleshooting

### Cron Job Not Running

```bash
# Check cron service
sudo systemctl status cron

# Check cron logs
sudo grep CRON /var/log/syslog

# Verify script permissions
ls -l /usr/local/bin/backup.sh

# Test script manually
sudo /usr/local/bin/backup.sh
```

### Rsync Errors

```bash
# Check source directory
ls -la /source_data

# Check destination permissions
ls -la /backup

# Test rsync with verbose output
rsync -avz --dry-run /source_data/ /backup/test/
```

### Disk Space Issues

```bash
# Check disk usage
df -h /backup

# Find large files
find /backup -type f -size +100M -exec ls -lh {} \;

# Clean old backups
find /backup/daily -name "backup_*" -mtime +7 -exec rm -rf {} \;
```

## Validation Checklist

- [ ] Backup script created and tested
- [ ] Cron jobs configured and running
- [ ] Rsync backups working correctly
- [ ] Backup rotation functioning
- [ ] Log rotation configured
- [ ] Restore procedure tested
- [ ] Monitoring script operational
- [ ] Documentation completed
- [ ] Screenshots captured

## Next Steps

Proceed to `cleanup.md` to remove lab resources when complete.
