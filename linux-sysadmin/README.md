# Linux System Administration Labs

## Overview

This section demonstrates **core Linux system administration skills** that form the foundation of cloud engineering and DevOps roles.

Each lab is designed to mirror **real-world scenarios** that system administrators encounter in production environments.

---

## 🎯 What These Labs Prove

✅ **User & Permission Management** - RBAC, sudo, groups, ACLs  
✅ **Service Management** - systemd, web servers, automation  
✅ **Backup & Recovery** - rsync, cron, restore validation  
✅ **Troubleshooting** - Log analysis, incident response  
✅ **Performance Monitoring** - Resource analysis, tuning  

---

## 📚 Labs

### 01 - Multi-User RBAC & sudo

**Path**: `01-multi-user-rbac-sudo/`

**What You'll Build**:

- Multiple users with different permission levels
- Group-based access control
- Controlled privilege escalation with sudo
- SetGID for shared project directories

**Skills Demonstrated**:

- Linux permission model
- Group management
- sudo configuration
- ACL implementation

**Real-World Application**:

- Team access control
- Least privilege principle
- Secure multi-user environments

---

### 02 - NGINX Web Server Deployment

**Path**: `02-nginx-or-apache-webserver/`

**What You'll Build**:

- Production-style web server
- Custom document root
- systemd service management
- Firewall configuration

**Skills Demonstrated**:

- Web server installation & configuration
- systemd service control
- Network security (firewall rules)
- File permissions for web content

**Real-World Application**:

- Hosting web applications
- Reverse proxy configuration
- Service lifecycle management

---

### 03 - Automated Backups with cron + rsync

**Path**: `03-backups-cron-rsync-rotation/`

**What You'll Build**:

- Automated backup system
- Timestamped backup directories
- Scheduled execution with cron
- Restore test validation

**Skills Demonstrated**:

- rsync for incremental backups
- cron job scheduling
- Bash scripting
- Backup verification

**Real-World Application**:

- Data protection
- Disaster recovery planning
- Operational reliability

**Critical Principle**: _Backups are meaningless unless you can restore_

---

### 04 - Logs, Troubleshooting & Incident Simulation

**Path**: `04-logs-troubleshooting-incident-sim/`

**What You'll Build**:

- Simulated service failure
- Log-based root cause analysis
- Incident report documentation
- Service recovery

**Skills Demonstrated**:

- journalctl and systemd logs
- Service status analysis
- Root cause identification
- Incident documentation

**Real-World Application**:

- Production outage response
- Post-mortem analysis
- Operational documentation

---

### 05 - Monitoring & Performance Tuning

**Path**: `05-monitoring-performance-tuning/`

**What You'll Build**:

- System baseline assessment
- Resource utilization analysis
- Performance optimization
- Monitoring documentation

**Skills Demonstrated**:

- CPU, memory, disk analysis
- Load average interpretation
- System tuning
- Performance metrics

**Real-World Application**:

- Capacity planning
- Performance optimization
- Resource efficiency

---

## 🔧 Tools & Technologies

**Core Linux Tools**:

- `systemd` - Service management
- `journalctl` - Log analysis
- `rsync` - File synchronization
- `cron` - Job scheduling
- `ufw` / `firewalld` - Firewall management

**Monitoring Tools**:

- `htop` - Process monitoring
- `free` - Memory analysis
- `df` - Disk usage
- `uptime` - Load averages
- `sysstat` - System statistics

---

## 📖 Lab Structure

Each lab contains:

```text
lab-name/
├── README.md           # What and why
├── steps.md            # How to build (step-by-step)
├── cleanup.md          # Safe teardown instructions
├── scripts/            # Automation scripts
│   └── README.md       # Script documentation
└── assets/             # Screenshots and proof of work
    └── screenshots/
```

---

## 🎓 Skills Progression

### Foundation → Intermediate → Advanced

```text
01. User Management     → Multi-user systems
02. Service Deployment  → Production services
03. Automation          → Scheduled operations
04. Troubleshooting     → Incident response
05. Performance         → System optimization
```

Each lab builds on previous concepts while introducing new skills.

---

## 💡 Best Practices Demonstrated

✅ **Documentation First** - Every change is documented  
✅ **Validation** - Test backups, verify configurations  
✅ **Security** - Least privilege, firewall rules, SSH keys  
✅ **Automation** - Scripts for repeatable tasks  
✅ **Operational Discipline** - Incident reports, cleanup procedures  

---

## 🚀 How to Use These Labs

### Prerequisites

- Linux environment (Ubuntu 20.04+ recommended)
- Basic command line familiarity
- Root/sudo access

### Approach

1. **Read** the lab README to understand objectives
2. **Follow** steps.md for implementation
3. **Document** your work with screenshots
4. **Test** functionality thoroughly
5. **Clean up** using cleanup.md

### Learning Path

- Complete labs in order (1 → 5)
- Each lab takes 1-3 hours
- Take screenshots of key steps
- Write notes about what you learned

---

## 📊 What Employers See

These labs prove you can:

- **Operate Linux systems** in real environments
- **Troubleshoot failures** using logs and system tools
- **Automate tasks** with scripts and cron
- **Secure systems** with proper permissions and firewalls
- **Document work** in a professional manner

This is **not memorized commands** - it's **real operational competence**.

---

## 🔗 Next Steps

After completing these labs:

1. **Azure Cloud Engineer** section - Move to cloud infrastructure
2. **DevOps** section - Learn automation and containers
3. **Real Application Deployment** - Build end-to-end systems

---

## 📌 Important Notes

- All labs are **safe for practice environments**
- Use **virtual machines or cloud instances** (not production)
- Follow **cleanup procedures** to avoid resource waste
- **Document everything** - screenshots prove your work

---

## 🤝 Real-World Alignment

These labs mirror actual tasks performed by:

- **Linux System Administrators**
- **Site Reliability Engineers (SRE)**
- **Cloud Infrastructure Engineers**
- **DevOps Engineers**

Every task here is something you'll do in a real job.

---

**Ready to begin?** Start with Lab 01: Multi-User RBAC & sudo
