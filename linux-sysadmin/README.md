# Linux Sysadmin Portfolio — Hands-On Production Labs

This repository documents my **hands-on Linux system administration journey**, built through **real-world, production-style labs**.

Every lab is:

- Built from scratch on Linux
- Fully documented step-by-step
- Validated with command output and screenshots
- Designed to mirror real on-call and production responsibilities

This is not theoretical learning — it reflects how Linux systems are **actually administered, secured, monitored, and recovered** in professional environments.

---

## 🔧 Skills Demonstrated

- Linux user & group management
- Role-based access control (RBAC)
- File permissions & ACLs
- Secure privilege escalation (sudo)
- Service deployment & management (systemd)
- Firewall configuration (UFW)
- Backup automation & restore validation
- Log analysis & incident response
- Performance monitoring & tuning
- Safe system limit configuration

---

## 📁 Lab Overview

### 🧑‍💻 Lab 1 — Multi-User Linux Server (RBAC, Permissions & Sudo)

**Folder:** `linux-sysadmin/01-multi-user-rbac-sudo`

#### What I built (Lab 1)

- Users and groups representing real roles (developers, auditors)
- Secure shared project directories using setgid + ACLs
- Controlled sudo access using `/etc/sudoers.d/`
- Full validation with real user testing

#### Key skills (Lab 1)

- `useradd`, `groupadd`, `usermod`
- `chmod`, `chown`, ACLs
- `visudo`, sudo hardening
- Access validation & auditing

---

### 🌐 Lab 2 — Linux Web Server (Nginx + Firewall Hardening)

**Folder:** `linux-sysadmin/02-nginx-or-apache-webserver`

#### What I built (Lab 2)

- Installed and configured Nginx with a custom server block
- Served content from `/var/www`
- Enabled and hardened firewall rules using UFW
- Verified exposed ports using socket inspection

#### Key skills (Lab 2)

- Nginx configuration
- `systemctl` service lifecycle
- Firewall security
- Network exposure validation

---

### 💾 Lab 3 — Automated Backups (rsync + cron + Restore Test)

**Folder:** `linux-sysadmin/03-backups-cron-rsync-rotation`

#### What I built (Lab 3)

- Automated backup script using `rsync`
- Timestamped backup directories
- Centralized logging
- Cron scheduling with absolute paths
- Restore test with checksum verification

#### Key skills (Lab 3)

- Backup strategy design
- Defensive Bash scripting
- Cron automation
- Disaster recovery validation

---

### 📄 Lab 4 — Log Management & Incident Simulation

**Folder:** `linux-sysadmin/04-logs-troubleshooting-incident-sim`

#### What I built (Lab 4)

- Simulated a real service outage
- Diagnosed failure using:
  - `systemctl`
  - `journalctl`
  - Application logs
- Restored service safely
- Wrote a formal incident report with prevention steps

#### Key skills (Lab 4)

- Incident response
- Log correlation
- Root cause analysis
- Production troubleshooting

---

### 📊 Lab 5 — Monitoring, Performance & System Limits

**Folder:** `linux-sysadmin/05-monitoring-performance-tuning`

#### What I built (Lab 5)

- Captured system baselines (CPU, memory, disk)
- Identified resource-heavy processes
- Analyzed disk usage and journald growth
- Used sysstat tools for I/O visibility
- Adjusted and validated system limits safely

#### Key skills (Lab 5)

- Performance monitoring
- Capacity awareness
- System tuning
- Risk-aware configuration changes

---

## 🧠 How This Maps to Real Jobs

These labs directly reflect responsibilities found in:

- Linux System Administrator
- Infrastructure Engineer
- Cloud Support Engineer
- Junior DevOps Engineer roles

Every lab includes:

- Real commands used in production
- Validation steps
- Documentation discipline
- Troubleshooting scenarios

---

## 🛡️ Security & Safety Notes

- No secrets or private keys are committed
- All environments are isolated lab systems
- Configuration changes are validated before reload/restart
- Restore and rollback paths are always tested

---

## 🚀 What’s Next

This Linux foundation is now being extended into:

- **Azure Linux infrastructure**
- Secure cloud networking
- VM hardening and monitoring
- Cloud-init automation
- Bastion and zero-trust access patterns

👉 See the upcoming `azure-cloud-engineer/` folder for cloud-based Linux labs.
