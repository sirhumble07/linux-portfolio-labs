# Linux & DevOps Engineering Portfolio

**Real infrastructure. Real deployments. Real skills.**

This repository demonstrates hands-on Linux system administration, cloud infrastructure, and DevOps engineering through **production-aligned labs** built on real systems.

Every project is:

- Implemented on actual Linux servers
- Fully documented with step-by-step instructions
- Validated with command output and screenshots
- Designed around real-world engineering responsibilities

---

## What This Portfolio Demonstrates

| Skill Area | What I've Built |
| ----------- | --------------- |
| **Linux Sysadmin** | Multi-user RBAC, web servers, backups, incident response, monitoring |
| **Azure Cloud** | Secure VMs, networking, NSGs, cloud-init, Bastion, monitoring |
| **DevOps** | Docker, CI/CD runners, reverse proxy, Bash automation, security hardening |
| **Application Deployment** | Full-stack app with FastAPI, PostgreSQL, workers, Nginx proxy |

---

## Repository Structure

```text
linux-portfolio-labs/
├── linux-sysadmin/          # Foundation: Linux system administration
├── azure-cloud-engineer/    # Cloud: Azure infrastructure & networking
├── devops/                  # Automation: Containers, CI/CD, scripting
└── uptime-monitor/          # Real App: Production-style deployment
```

---

## Linux System Administration

**Location:** `linux-sysadmin/`

Foundation skills for all cloud and DevOps work.

### Labs Completed

#### 01 - Multi-User RBAC & sudo

- Created users and groups with specific permissions
- Implemented SetGID for shared directories
- Configured sudo for controlled privilege escalation
- **Skills:** Linux permissions, RBAC, ACLs

#### 02 - Web Server Deployment

- Deployed Nginx web server
- Configured systemd service management
- Implemented firewall rules (ufw)
- **Skills:** Service lifecycle, networking, security

#### 03 - Automated Backups

- Implemented rsync-based backup automation
- Scheduled with cron
- Validated restore procedures
- **Skills:** Backup strategies, cron, disaster recovery

#### 04 - Incident Simulation & Troubleshooting

- Simulated service failures
- Analyzed logs with journalctl
- Performed root cause analysis
- **Skills:** Log analysis, debugging, incident response

#### 05 - Performance Monitoring & Tuning

- Monitored CPU, memory, disk I/O
- Used sysstat tools
- Identified and resolved bottlenecks
- **Skills:** Performance analysis, system tuning

### Why Linux Labs Matter

These labs prove **real Linux understanding**, not just command memorization. This is the foundation that cloud platforms and containers run on.

---

## Azure Cloud Engineering

**Location:** `azure-cloud-engineer/`

Enterprise cloud infrastructure patterns on Azure.

### Azure Labs Completed

#### 01 - Secure Linux VM Deployment

- Deployed VMs with SSH key authentication only
- Configured Network Security Groups (NSGs)
- Implemented least-privilege access
- **Skills:** VM security, network isolation

#### 02 - Cloud-Init Automation

- Automated VM provisioning with cloud-init
- Zero-touch configuration
- Standardized deployments
- **Skills:** Infrastructure automation, consistency

#### 03 - Azure Networking

- Created VNets and subnets
- Configured NSG rules
- Implemented network segmentation
- **Skills:** Cloud networking, traffic control

#### 04 - Monitoring & Alerts

- Set up Azure Monitor
- Created CPU and disk alerts
- Configured action groups
- **Skills:** Observability, proactive monitoring

#### 05 - Azure Bastion

- Deployed secure admin access
- Eliminated public IP exposure
- Implemented zero-trust pattern
- **Skills:** Secure access, compliance patterns

### Why Azure Labs Matter

These labs demonstrate **production cloud infrastructure** skills required in real Azure environments.

---

## ⚙️ DevOps Engineering

**Location:** `devops/`

Automation, containers, CI/CD, and security.

### DevOps Labs Completed

#### 01 - Linux Docker Host

- Installed and configured Docker Engine
- Created custom networks
- Managed persistent volumes
- Ran stateful containers (PostgreSQL)
- **Skills:** Containerization, storage, networking

#### 02 - Nginx Reverse Proxy

- Configured path-based routing
- Isolated backend services
- Tested failure scenarios
- Validated 502 error handling
- **Skills:** Traffic routing, service isolation, troubleshooting

#### 03 - Self-Hosted CI Runner

- Deployed GitHub Actions runner on Linux
- Registered to repository
- Configured as systemd service
- Tested failure recovery
- **Skills:** CI/CD internals, pipeline execution, service management

#### 04 - Bash Automation Toolkit

- Created system health check scripts
- Automated log cleanup safely
- Built idempotent user provisioning
- Implemented production-safe scripting
- **Skills:** Bash scripting, automation, idempotency

#### 05 - Linux Security Hardening

- Hardened SSH (keys only, no root)
- Configured UFW firewall
- Implemented fail2ban
- Created security audit checklist
- **Skills:** DevSecOps, attack surface reduction, compliance

### Why DevOps Labs Matter

These labs demonstrate **operational DevOps competence** — how systems are built, deployed, secured, and maintained in real environments.

---

## Real Application Deployment

**Location:** `uptime-monitor/`

A production-style uptime monitoring application demonstrating end-to-end system ownership.

### What It Does

- Users log in and add URLs to monitor
- Background worker checks uptime every 5 minutes
- Results stored in PostgreSQL
- Dashboard displays status and history

### Architecture

```text
Internet
    ↓
Nginx (reverse proxy + static UI)
    ↓
FastAPI (authentication + API)
    ↓
PostgreSQL (data persistence)
    ↓
Worker (scheduled checks)
```

### Technologies

- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL
- **Worker:** Scheduled background processing
- **Proxy:** Nginx
- **Orchestration:** Docker Compose
- **CI/CD:** GitHub Actions
- **Infrastructure:** Azure Linux VM

### CI/CD Pipeline

1. Code pushed to GitHub
2. GitHub Actions triggers workflow
3. Self-hosted runner executes pipeline
4. Runner SSHs to Azure VM
5. VM pulls latest code
6. Docker Compose rebuilds services
7. Zero-downtime deployment

### Why This Project Matters

This demonstrates:

- ✅ Multi-container orchestration
- ✅ Stateful service management
- ✅ Background job processing
- ✅ Reverse proxy configuration
- ✅ Automated deployment to cloud
- ✅ End-to-end system ownership

---

## 🔐 Security Best Practices

Throughout all labs:

- ✅ SSH key authentication only (no passwords)
- ✅ Firewall rules restricting access
- ✅ fail2ban for intrusion prevention
- ✅ Secrets excluded from version control
- ✅ Container isolation
- ✅ Least-privilege access patterns
- ✅ Network segmentation

---

## 📖 How to Use This Repository

Each lab includes:

- **README.md** - Overview and learning objectives
- **steps.md** - Step-by-step implementation guide
- **cleanup.md** - Safe teardown instructions
- **Screenshots** - Validation evidence

Everything is:

- ✅ Reproducible
- ✅ Well-documented
- ✅ Production-aligned
- ✅ Security-conscious

---

## 🎓 Skills Progression

This portfolio follows a **logical learning path**:

1. **Linux Foundation** → Core OS and system administration
2. **Cloud Infrastructure** → Azure platform and networking
3. **DevOps Practices** → Automation, containers, CI/CD
4. **Real Application** → End-to-end system deployment

This mirrors how engineers **actually build and operate systems** in real jobs.

---

## Future Enhancements

Potential additions:

- HTTPS with Let's Encrypt
- Infrastructure as Code (Terraform/Bicep)
- Kubernetes deployment
- Prometheus & Grafana monitoring
- Azure Key Vault integration
- Multi-region deployment

---

## What This Portfolio Proves

| Role | Demonstrated Skills |
| ---- | ----------------- |
| **Linux Engineer** | System administration, troubleshooting, automation |
| **Cloud Engineer** | Azure infrastructure, networking, security |
| **DevOps Engineer** | CI/CD, containers, scripting, deployment |
| **Platform Engineer** | Service orchestration, automation, monitoring |

---

## Contact

**Victor Nwoke**  
[Email] <victornwoke147@outlook.com> • [LinkedIn](https://www.linkedin.com/in/victornwoke/) • [GitHub](https://github.com/sirhumble07/)

---

**This is not a tutorial collection. This is a working engineering portfolio demonstrating real infrastructure skills.**
