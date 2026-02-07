# 📁 Cloud & DevOps Engineering Portfolio  

## Linux • Azure • DevOps • Real Application Deployment

This repository is a **hands-on engineering portfolio** demonstrating how modern infrastructure, cloud platforms, and DevOps practices work together in real environments.

It is intentionally **lab-driven**, **production-aligned**, and **fully reproducible**.

---

## 🧠 How to Read This Repo

This repository is structured in a **progressive, real-world order**:

1. **Linux Sysadmin** – Operating system fundamentals  
2. **Azure Cloud Engineer** – Cloud infrastructure & networking  
3. **DevOps** – Automation, containers, CI/CD  
4. **Real Application Deployment** – End-to-end system in production style  

This mirrors how engineers actually **learn, build, and operate systems** in real jobs.

---

## 🐧 Linux Sysadmin Labs (Foundation)

📂 `linux-sysadmin/`

These labs focus on **core Linux system administration**, the foundation of all cloud and DevOps roles.

### Linux Labs

- **Multi-user RBAC & sudo**
  - Users, groups, ACLs, SetGID, controlled privilege escalation
- **Web server deployment**
  - Nginx, systemd, firewall configuration
- **Automated backups**
  - rsync, cron scheduling, restore validation
- **Incident simulation & troubleshooting**
  - Service failure, log analysis, root cause investigation
- **Monitoring & performance tuning**
  - CPU, memory, disk, limits, sysstat tools

### Linux Skills Demonstrated

- Linux permission model
- Service lifecycle management
- Log-based troubleshooting
- Bash scripting
- Defensive operations

✅ Proves **real Linux understanding**, not just commands.

---

## ☁️ Azure Cloud Engineer Labs

📂 `azure-cloud-engineer/`

These labs move Linux workloads into **real Azure environments** using enterprise patterns.

### Azure Labs

- **Secure Linux VM deployment**
  - SSH keys only
  - NSG-restricted access
- **cloud-init automation**
  - Zero-touch provisioning
  - Standardized VM bootstrap
- **Azure networking**
  - VNets, subnets, NSGs
  - Controlled east–west traffic
- **Monitoring & alerts**
  - Azure Monitor
  - CPU and disk alerts
- **Azure Bastion**
  - Zero public IP access
  - Enterprise admin pattern

### Azure Skills Demonstrated

- Azure VM security
- Network segmentation
- Cloud automation
- Monitoring & alerting
- Zero-trust access concepts

✅ Proves **Linux + Cloud integration skills**.

---

## ⚙️ DevOps Labs (Automation & Delivery)

📂 `devops/`

These labs focus on **how systems are built, delivered, and operated**.

### DevOps Labs

- **Docker host & containers**
  - Networks, volumes, persistence
- **Nginx reverse proxy**
  - Path-based routing
  - Failure simulation
- **Self-hosted CI runner**
  - GitHub Actions on Linux
- **Bash automation toolkit**
  - Health checks
  - Log cleanup
  - Idempotent user provisioning
- **Linux security hardening**
  - SSH, firewall, fail2ban

### DevOps Skills Demonstrated

- Containerization fundamentals
- CI/CD execution environments
- Automation mindset
- DevSecOps basics
- Failure recovery

✅ Proves **operational DevOps competence**.

---

## 🚀 Real Application Deployment Project

📂 `uptime-monitor/`

A **production-style mini SaaS** that connects Linux, Azure, and DevOps into one system.

### What the App Does

- User authentication
- Add URLs to monitor
- Background worker checks uptime every 5 minutes
- Results stored and displayed in a dashboard

### Architecture

Internet
|
Nginx (reverse proxy + UI)
|
FastAPI (authentication + API)
|
Postgres (persistent data)
|
Worker (scheduled checks)

### Technologies Used

- FastAPI (Python)
- PostgreSQL
- Background worker
- Docker Compose
- Nginx
- GitHub Actions
- Azure Virtual Machine

### Why This Project Matters

Demonstrates:

- Multi-container orchestration
- Stateful services
- Scheduled background processing
- Reverse proxy routing
- CI/CD deployment to cloud infrastructure

✅ Proves **end-to-end system ownership**.

---

## 🔁 CI/CD Flow

1. Code pushed to GitHub
2. GitHub Actions triggers
3. Self-hosted Linux runner executes pipeline
4. Runner SSHs into Azure VM
5. VM pulls latest code
6. Docker Compose rebuilds and restarts services

No abstractions. No shortcuts. **Real infrastructure behavior**.

---

## 🔐 Security & Best Practices

- SSH key-based authentication
- Password logins disabled
- Firewall-restricted access
- fail2ban intrusion prevention
- Secrets excluded from Git
- Container isolation
- Idempotent scripts

---

## 📌 How to Use This Repo

Each lab includes:

- `README.md` — what and why
- `steps.md` — how to build
- `cleanup.md` — safe teardown

Everything is:

- Reproducible
- Auditable
- Production-aligned

---

## 🧭 What This Portfolio Demonstrates

✔ Linux fundamentals  
✔ Azure cloud infrastructure  
✔ DevOps automation  
✔ Security awareness  
✔ Real application deployment  
✔ Structured problem-solving  

---

## 🧩 Future Extensions (Optional)

- HTTPS with Let’s Encrypt
- Terraform or Bicep
- Kubernetes version
- Prometheus & Grafana
- Azure Key Vault integration

---

### Final Note

This repository is **not a tutorial dump**.  
It is a **real engineering portfolio** showing how systems work end to end.