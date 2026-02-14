# Bash Ops Automation Toolkit

## STEP 1 — Bash safety baseline (CRITICAL)

Every production script must start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

**What this does:**

- `-e` → exit on error
- `-u` → fail on undefined variables
- `pipefail` → catch failures in pipelines

This prevents silent failures — a major ops risk.

---

## STEP 2 — Script 1: System Health Check

Create `scripts/health_check.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== SYSTEM HEALTH CHECK ==="
echo "Hostname: $(hostname)"
echo "Uptime:"
uptime
echo

echo "CPU & Load:"
nproc
uptime | awk -F'load average:' '{ print $2 }'
echo

echo "Memory:"
free -h
echo

echo "Disk Usage:"
df -h | grep -E '^Filesystem|^/dev/'
echo

echo "Top Processes:"
ps aux --sort=-%mem | head -n 6
```

Make executable:

```bash
chmod +x scripts/health_check.sh
```

Run it:

```bash
./scripts/health_check.sh
```

📸 **Screenshot:** full script output

🔍 **Why this script matters:**

This is exactly what engineers run:

- during incidents
- during handover
- in cron jobs
- inside CI runners

---

## STEP 3 — Script 2: Safe Log Cleanup

Create `scripts/cleanup_logs.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/log"
DAYS=14

echo "Cleaning logs older than $DAYS days in $LOG_DIR"

find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -print -delete

echo "Cleanup complete."
```

Make executable:

```bash
chmod +x scripts/cleanup_logs.sh
```

**Dry-run test (IMPORTANT):**

```bash
sudo find /var/log -type f -name "*.log" -mtime +14 -print | head
```

Run cleanup:

```bash
sudo ./scripts/cleanup_logs.sh
```

📸 **See Screenshot:** dry-run output + cleanup execution

🔍 **Why this is written carefully:**

- Uses file age (`-mtime`)
- Restricts file pattern
- Avoids `rm -rf`
- Prevents deleting active logs

---

## STEP 4 — Script 3: User Provisioning (Repeatable & Safe)

Create `scripts/provision_user.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER="$1"

if id "$USER" &>/dev/null; then
  echo "User $USER already exists"
  exit 0
fi

sudo useradd -m -s /bin/bash "$USER"
sudo passwd "$USER"
sudo usermod -aG sudo "$USER"

echo "User $USER created and added to sudo group"
```

Make executable:

```bash
chmod +x scripts/provision_user.sh
```

Run:

```bash
./scripts/provision_user.sh devopsuser1
```

Validate:

```bash
id devopsuser1
```

📸 **See Screenshot:** script execution + `id devopsuser1`

🔍 **Why this matters in real teams:**

- Scripts must be idempotent
- Must validate input
- Must not break if run twice
- Must explain usage clearly

---

## STEP 5 — Optional automation (cron example)

Add health check to cron:

```bash
crontab -e
```

Add this line:

```text
0 * * * * /home/<user>/devops/04-bash-ops-automation-toolkit/scripts/health_check.sh >> ~/health.log
```

📸 **See Screenshot:** crontab entry
