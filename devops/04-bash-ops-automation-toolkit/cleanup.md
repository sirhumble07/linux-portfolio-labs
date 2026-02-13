# Cleanup Guide - Bash Ops Automation Toolkit

## Remove Test User

If you created a test user during the lab, remove it:

```bash
# Delete the user and their home directory
sudo userdel -r devopsuser1

# Verify removal
id devopsuser1
# Should output: id: 'devopsuser1': no such user
```

---

## Remove Cron Job

If you added a cron job:

```bash
# Edit crontab
crontab -e

# Remove the line:
# 0 * * * * /home/<user>/devops/04-bash-ops-automation-toolkit/scripts/health_check.sh >> ~/health.log

# Verify removal
crontab -l
```

---

## Remove Log Files

If you generated test logs:

```bash
# Remove health check logs
rm -f ~/health.log

# Check for any test logs created
ls -lh ~/devops/04-bash-ops-automation-toolkit/
```

---

## Optional: Remove Scripts Directory

If you want to completely remove the project:

```bash
cd ~/devops
rm -rf 04-bash-ops-automation-toolkit
```

**Warning:** This will delete all scripts and documentation.

---

## Verify Cleanup

```bash
# Check no cron jobs remain
crontab -l | grep health_check

# Check user is removed
id devopsuser1 2>&1

# Check directory
ls -la ~/devops/04-bash-ops-automation-toolkit
```

---

## System State Check

After cleanup, verify system is clean:

```bash
# Check for any leftover processes
ps aux | grep -i health_check

# Check disk space recovered
df -h

# Check users
cat /etc/passwd | grep devopsuser
```

All commands should return no results or indicate items don't exist.

---

## Notes

- This lab made no permanent system changes beyond the test user
- All scripts were contained in user space
- No system packages were installed
- No system configuration files were modified
