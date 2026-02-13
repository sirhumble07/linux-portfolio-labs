# Cleanup Guide - Self-Hosted GitHub Actions Runner

## Overview

This guide walks you through properly removing all resources created during the Self-Hosted GitHub Actions Runner lab. Follow these steps to ensure complete cleanup without leaving orphaned processes or configurations.

---

## Pre-Cleanup Checklist

Before removing resources, verify what's currently running:

```bash
# Check runner service status
sudo ./svc.sh status

# List running containers (if any workflows are executing)
docker ps

# Check disk usage
df -h ~/actions-runner
```

📸 **Screenshot:** Pre-cleanup system status

---

## Step 1: Stop Active Workflows

### Check for Running Jobs

In GitHub UI:

1. Go to your repository
2. Click **Actions** tab
3. Check if any workflows are currently running

**If workflows are running:**

- Wait for them to complete, OR
- Cancel them manually in GitHub UI

**Why this matters:** Stopping the runner while jobs are executing will cause those jobs to fail.

---

## Step 2: Stop the Runner Service

### Stop Service Gracefully

```bash
# Navigate to runner directory
cd ~/actions-runner

# Stop the service
sudo ./svc.sh stop
```

**Expected output:**

```text
Stopping runner service...
Runner service stopped successfully
```

### Verify Service is Stopped

```bash
# Check service status
sudo ./svc.sh status

# Alternative verification
ps aux | grep Runner.Listener
```

**Expected output:**

- Service should show as "inactive (dead)"
- No Runner.Listener processes running

📸 **Screenshot:** Stopped service status

---

## Step 3: Uninstall the Service

### Remove from systemd

```bash
# Uninstall the service
sudo ./svc.sh uninstall
```

**Expected output:**

```text
Uninstalling runner service...
Service uninstalled successfully
```

### Verify Service Removal

```bash
# Check if service file is removed
sudo systemctl list-units --all | grep actions.runner

# Alternative check
ls /etc/systemd/system/ | grep actions.runner
```

**Expected output:**

- No actions.runner service files should exist

### Reload systemd

```bash
# Reload systemd daemon to clean up
sudo systemctl daemon-reload
```

📸 **Screenshot:** Service uninstalled confirmation

---

## Step 4: Remove Runner from GitHub

### Deregister Runner

```bash
# Navigate to runner directory (if not already there)
cd ~/actions-runner

# Remove runner configuration
./config.sh remove
```

**You'll be prompted for a removal token:**

1. Go to GitHub: **Settings** → **Actions** → **Runners**
2. Click on your runner
3. Click **Remove runner**
4. Copy the removal token shown
5. Paste token when prompted in terminal

**Expected output:**

```text
√ Successfully removed runner
```

### Verify in GitHub UI

1. Go to **Settings** → **Actions** → **Runners**
2. Your runner should no longer be listed

📸 **Screenshot:** Runner removed from GitHub UI

---

## Step 5: Remove Runner Directory

### Backup Configuration (Optional)

If you want to keep your configuration for reference:

```bash
# Create backup
cd ~
tar -czf actions-runner-backup-$(date +%Y%m%d).tar.gz actions-runner/

# Move to safe location
mkdir -p ~/backups
mv actions-runner-backup-*.tar.gz ~/backups/
```

### Remove Runner Directory

```bash
# Navigate to home directory
cd ~

# Remove runner directory
rm -rf actions-runner/
```

### Verify Removal

```bash
# Check directory is gone
ls -la ~ | grep actions-runner

# Verify disk space freed
df -h ~
```

**Expected output:**

- No actions-runner directory should exist

📸 **Screenshot:** Directory removed confirmation

---

## Step 6: Clean Up Docker Resources (Optional)

If you ran workflows that created Docker containers or images:

### Remove Workflow Artifacts

```bash
# List Docker containers created by workflows
docker ps -a

# Remove all stopped containers
docker container prune -f

# List Docker images
docker images

# Remove unused images
docker image prune -a -f
```

### Clean Docker Build Cache

```bash
# Remove build cache
docker builder prune -a -f

# Check freed space
docker system df
```

**Warning:** This removes all Docker resources, not just runner-related ones. Only run if you're sure.

📸 **Screenshot:** Docker cleanup results

---

## Step 7: Remove Log Files

### Locate Log Files

```bash
# Find runner-related logs
sudo journalctl -u actions.runner.* --no-pager | head -1
```

### Clean System Logs

```bash
# Remove runner service logs from journald
sudo journalctl --vacuum-time=1s -u actions.runner.*

# Verify logs removed
sudo journalctl -u actions.runner.* --no-pager
```

**Expected output:**

- "No entries" or "Data already removed"

---

## Step 8: Remove Monitoring Scripts (If Created)

If you created monitoring scripts during the lab:

```bash
# Remove monitoring scripts
rm -f ~/monitor-runner.sh
rm -f ~/runner-health-check.sh

# Remove cron jobs (if any)
crontab -l | grep -v runner | crontab -
```

---

## Step 9: Remove Logrotate Configuration (If Created)

If you configured log rotation:

```bash
# Remove logrotate configuration
sudo rm -f /etc/logrotate.d/github-runner

# Verify removal
ls /etc/logrotate.d/ | grep github-runner
```

---

## Step 10: Remove User Account (If Created Dedicated User)

If you created a dedicated `github-runner` user:

```bash
# Stop any processes running as github-runner
sudo pkill -u github-runner

# Remove user account
sudo userdel -r github-runner

# Verify removal
id github-runner
```

**Expected output:**

- "id: 'github-runner': no such user"

---

## Step 11: Clean Up Workflow Files (Optional)

If you want to remove the test workflows from your repository:

```bash
# Navigate to repository
cd /path/to/your/repo

# Remove workflow files
rm -rf .github/workflows/

# Commit changes
git add .github/
git commit -m "Remove self-hosted runner workflows"
git push origin main
```

**Note:** Only do this if you're done with the workflows.

---

## Step 12: Verify Complete Cleanup

Run comprehensive checks to ensure everything is removed:

```bash
# Check for runner processes
ps aux | grep -i runner | grep -v grep

# Check for runner services
sudo systemctl list-units --all | grep actions

# Check for runner directories
find ~ -type d -name "*runner*" 2>/dev/null

# Check for runner files in systemd
sudo find /etc/systemd -name "*runner*"

# Check GitHub UI
# Settings → Actions → Runners (should be empty)
```

**Expected results:**

- No runner processes
- No runner services
- No runner directories
- No systemd runner files
- No runners in GitHub UI

📸 **Screenshot:** Clean system verification

---

## Cleanup Summary

### What Was Removed

✅ GitHub Actions runner service  
✅ Runner configuration and registration  
✅ Runner binaries and directories  
✅ System service files (systemd)  
✅ Runner logs (journalctl)  
✅ Monitoring scripts (if created)  
✅ Docker artifacts from workflows  
✅ Runner from GitHub UI  

### What Remains (Intentionally)

- Docker Engine (still installed)
- Your GitHub repository
- VM and its base configuration
- Other system services and applications

---

## Troubleshooting Cleanup Issues

### Issue: Service Won't Stop

**Error:** "Failed to stop runner service"

**Solution:**

```bash
# Force kill the process
sudo pkill -9 -f Runner.Listener

# Then try uninstalling again
sudo ./svc.sh uninstall
```

---

### Issue: Can't Remove Runner from GitHub

**Error:** "Removal token invalid"

**Solution:**

1. Go to GitHub UI: **Settings** → **Actions** → **Runners**
2. Click on your runner
3. Click **Remove runner** and copy new token
4. Run: `./config.sh remove` with new token

Alternatively, manually remove from GitHub UI:

1. Click on runner name
2. Click **Remove** button
3. Confirm removal

---

### Issue: Directory Won't Delete

**Error:** "Directory not empty" or "Permission denied"

**Solution:**

```bash
# Check what's holding the directory
lsof +D ~/actions-runner/

# Force remove with sudo if needed
sudo rm -rf ~/actions-runner/

# Change ownership first if necessary
sudo chown -R $(whoami):$(whoami) ~/actions-runner/
rm -rf ~/actions-runner/
```

---

### Issue: Docker Won't Remove Containers

**Error:** "Container is in use"

**Solution:**

```bash
# Stop all containers first
docker stop $(docker ps -aq)

# Then remove
docker rm $(docker ps -aq)

# Force remove if needed
docker rm -f $(docker ps -aq)
```

---

## Post-Cleanup Verification Commands

Run these commands to verify complete cleanup:

```bash
#!/bin/bash

echo "=== Checking for Runner Processes ==="
ps aux | grep -i runner | grep -v grep || echo "✓ No runner processes"
echo ""

echo "=== Checking for Runner Services ==="
sudo systemctl list-units --all | grep actions || echo "✓ No runner services"
echo ""

echo "=== Checking for Runner Directories ==="
ls -la ~ | grep actions-runner || echo "✓ No runner directories"
echo ""

echo "=== Checking Disk Usage ==="
df -h ~
echo ""

echo "=== Cleanup Complete ==="
```

📸 **Screenshot:** Post-cleanup verification results

---

## Re-Installation

If you want to set up the runner again:

1. Start from Step 1 in `steps.md`
2. Follow all configuration steps
3. Get a new registration token from GitHub
4. Configure runner with new settings

**Note:** You can reuse the same runner name if it was properly removed from GitHub.

---

## Next Steps After Cleanup

- Review your screenshots and documentation
- Update your portfolio with findings
- Consider running the lab again for practice
- Move on to the next lab in the series
- Try advanced runner configurations (multiple runners, runner pools, etc.)

---

## Quick Cleanup Script

For convenience, here's a one-liner to remove everything:

```bash
# WARNING: This will remove EVERYTHING related to the runner
cd ~/actions-runner && \
sudo ./svc.sh stop && \
sudo ./svc.sh uninstall && \
./config.sh remove && \
cd ~ && \
rm -rf actions-runner/ && \
docker system prune -af && \
echo "Cleanup complete! Check GitHub UI to verify runner removal."
```

**Use with caution!** This script assumes you want to remove everything immediately.

---

## Questions or Issues?

If you encounter cleanup issues:

1. Check service logs: `sudo journalctl -u actions.runner.* -n 50`
2. Review GitHub UI for runner status
3. Verify no workflows are running
4. Check for file permission issues
5. Ensure you have sudo access
6. Try rebooting the VM as a last resort

---

**Cleanup complete! Your system is now ready for the next lab or runner reinstallation.** 🎉
