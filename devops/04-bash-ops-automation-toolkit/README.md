# Bash Ops Automation Toolkit

**A production-grade collection of Bash scripts for system administration and DevOps automation.**

## 📋 Overview

This project demonstrates essential bash scripting skills required in DevOps roles:

- System health monitoring
- Automated log cleanup
- User provisioning
- Safe scripting practices
- Production-ready error handling

## 🎯 Skills Demonstrated

- **Bash Scripting:** Writing production-safe scripts with proper error handling
- **System Administration:** Health checks, user management, log rotation
- **Automation:** Cron scheduling, idempotent operations
- **Best Practices:** Input validation, dry-run testing, documentation

## 📁 Project Structure

```text
04-bash-ops-automation-toolkit/
├── README.md                    # This file
├── steps.md                     # Step-by-step implementation guide
├── cleanup.md                   # Cleanup instructions
└── scripts/
    ├── health_check.sh         # System health monitoring
    ├── cleanup_logs.sh         # Safe log file cleanup
    └── provision_user.sh       # User provisioning automation
```

## 🚀 Quick Start

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Bash 4.0+
- sudo access (for user provisioning)

### Setup

1. **Clone or navigate to this directory:**

   ```bash
   cd ~/devops/04-bash-ops-automation-toolkit
   ```

2. **Create scripts directory:**

   ```bash
   mkdir -p scripts
   ```

3. **Follow the step-by-step guide:**

   ```bash
   cat steps.md
   ```

## 📜 Script Details

### 1. Health Check Script

**Purpose:** Monitor system resources and performance

**Usage:**

```bash
./scripts/health_check.sh
```

**Checks:**

- System uptime
- CPU cores and load average
- Memory usage
- Disk space
- Top memory-consuming processes

**Output Example:**

```text
=== SYSTEM HEALTH CHECK ===
Hostname: devops-lab
Uptime: up 2 days, 3:45

CPU & Load:
4
 0.15, 0.10, 0.08

Memory:
              total        used        free
Mem:           15Gi       3.2Gi        11Gi
```

---

### 2. Log Cleanup Script

**Purpose:** Safely remove old log files to free disk space

**Usage:**

```bash
sudo ./scripts/cleanup_logs.sh
```

**Features:**

- Targets logs older than 14 days
- Restricts to `.log` files only
- Uses safe `find` with `-mtime` instead of `rm -rf`
- Includes dry-run testing capability

**Safety measures:**

- No recursive deletion of directories
- File age verification
- Pattern matching to avoid system files

---

### 3. User Provisioning Script

**Purpose:** Create users consistently and safely

**Usage:**

```bash
./scripts/provision_user.sh <username>
```

**Features:**

- Input validation
- Idempotent (safe to run multiple times)
- Creates home directory
- Sets bash shell
- Adds user to sudo group

**Example:**

```bash
./scripts/provision_user.sh devopsuser1
```

## 🛡️ Safety Features

All scripts include:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

**This ensures:**

- `-e`: Exit immediately on error
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Catch failures in pipes

## 🔧 Advanced Usage

### Scheduling with Cron

Run health checks hourly:

```bash
crontab -e
```

Add:

```text
0 * * * * /home/<user>/devops/04-bash-ops-automation-toolkit/scripts/health_check.sh >> ~/health.log 2>&1
```

### Customization

**Adjust log cleanup retention:**

```bash
# Edit scripts/cleanup_logs.sh
DAYS=30  # Change from 14 to 30 days
```

**Change log directory:**

```bash
LOG_DIR="/var/log/myapp"
```

## 📊 Testing

### Dry-Run Testing

Before running destructive operations:

```bash
# Test log cleanup without deleting
sudo find /var/log -type f -name "*.log" -mtime +14 -print

# Test user creation
id testuser  # Check if user exists first
```

### Validation

```bash
# Verify health check output
./scripts/health_check.sh | grep "SYSTEM HEALTH"

# Verify user creation
id devopsuser1
sudo -l -U devopsuser1
```

## 📝 Interview Talking Points

### "Walk me through a bash script you've written"

> "I created a system health check script that runs in production environments. It starts with `set -euo pipefail` for safety, then collects system metrics like CPU load, memory, and disk usage. I used command substitution and piping to format output, and it's designed to be cron-friendly with clear, parseable output. I tested it thoroughly including edge cases like full disks."

### "How do you ensure bash scripts are production-safe?"

> "I always start with `set -euo pipefail` to catch errors early. I validate all inputs, use quotes around variables to prevent word splitting, and make scripts idempotent so they can run multiple times safely. For destructive operations like log cleanup, I implement dry-run testing with `find -print` before `find -delete`. I also avoid `rm -rf` and use specific file patterns."

### "Describe automating a manual task"

> "I automated user provisioning that was previously done manually. The script validates input, checks if the user exists to make it idempotent, creates the user with a home directory, and adds them to the sudo group. This eliminated inconsistencies and reduced provisioning time from 10 minutes to 30 seconds while ensuring no steps were missed."

## 🧹 Cleanup

See [cleanup.md](cleanup.md) for complete removal instructions.

Quick cleanup:

```bash
# Remove test user
sudo userdel -r devopsuser1

# Remove cron jobs
crontab -e  # Delete relevant lines

# Remove project (optional)
rm -rf ~/devops/04-bash-ops-automation-toolkit
```

## 📚 Learning Resources

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

## ⚠️ Important Notes

- These scripts require sudo access for certain operations
- Always test scripts in a safe environment first
- Review and understand each script before running
- Backup important data before running cleanup operations

## 🔗 Related Projects

- [Linux Server Setup](../01-linux-server-setup/)
- [Docker Multi-Container App](../02-docker-multi-container-app/)
- [Self-Hosted CI Runner](../03-self-hosted-ci-runner/)

## 📄 License

This project is part of a DevOps portfolio for educational purposes.

---

**Author:** Your Name  
**Last Updated:** February 2026
