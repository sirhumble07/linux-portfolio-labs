# DevOps Engineering Labs

**Automation, containers, CI/CD, and security hardening on real Linux systems.**

This section demonstrates practical DevOps engineering skills: containerization, reverse proxies, self-hosted CI/CD runners, bash automation, and security hardening.

---

## 🎯 What These Labs Demonstrate

| Lab | Core Skills | Technologies |
| --- | ---------- | ------------ |
| **01 - Linux Docker Host** | Container runtime, networking, volumes | Docker, PostgreSQL |
| **02 - Nginx Reverse Proxy** | Traffic routing, service isolation | Nginx, Docker |
| **03 - Self-Hosted CI Runner** | CI/CD infrastructure, pipeline execution | GitHub Actions, systemd |
| **04 - Bash Automation Toolkit** | Safe scripting, automation, idempotency | Bash, cron |
| **05 - Security Hardening** | DevSecOps, attack surface reduction | SSH, UFW, fail2ban |

---

## 📁 Lab Structure

```text
devops/
├── 01-linux-docker-host/
│   ├── README.md
│   ├── steps.md
│   └── cleanup.md
├── 02-nginx-reverse-proxy/
│   ├── README.md
│   ├── steps.md
│   └── cleanup.md
├── 03-self-hosted-ci-runner/
│   ├── README.md
│   ├── steps.md
│   ├── ci-notes.md
│   └── cleanup.md
├── 04-bash-ops-automation-toolkit/
│   ├── README.md
│   ├── steps.md
│   ├── cleanup.md
│   └── scripts/
│       ├── health_check.sh
│       ├── cleanup_logs.sh
│       └── provision_user.sh
└── 05-linux-security-hardening-devsecops/
    ├── README.md
    ├── steps.md
    ├── hardening-checklist.md
    └── cleanup.md
```

---

## 🐳 Lab 01 - Linux Docker Host

**Skills:** Container runtime, persistent storage, networking

### What You'll Build - Docker Host

- Install and configure Docker Engine on Linux
- Create custom Docker networks
- Manage persistent volumes
- Run stateful containers (PostgreSQL)

### Key Concepts - Docker Host

- Container lifecycle management
- Volume mounting for data persistence
- Network isolation between containers
- Docker daemon configuration

### Technologies Used - Docker Host

- Docker Engine
- PostgreSQL container
- Custom bridge networks
- Named volumes

📂 **[Go to Lab 01](01-linux-docker-host/)**

---

## 🔀 Lab 02 - Nginx Reverse Proxy

**Skills:** Traffic routing, service isolation, troubleshooting

### What You'll Build - Reverse Proxy

- Configure Nginx as a reverse proxy
- Implement path-based routing
- Isolate backend services
- Test and validate failure scenarios

### Key Concepts - Reverse Proxy

- Reverse proxy patterns
- Path-based routing (`/api`, `/admin`)
- 502 error handling
- Service health checks

### Technologies Used - Reverse Proxy

- Nginx
- Docker containers
- HTTP routing
- Backend service isolation

📂 **[Go to Lab 02](02-nginx-reverse-proxy/)**

---

## 🔄 Lab 03 - Self-Hosted CI Runner

**Skills:** CI/CD infrastructure, pipeline execution, service management

### What You'll Build - CI Runner

- Deploy GitHub Actions runner on Linux
- Register runner to GitHub repository
- Configure as systemd service
- Test automated workflows
- Implement failure recovery

### Key Concepts - CI Runner

- Self-hosted CI/CD architecture
- Runner authentication and registration
- Service lifecycle management
- Workflow triggers and execution
- Pipeline debugging

### Technologies Used - CI Runner

- GitHub Actions
- systemd
- Bash scripting
- CI/CD workflows

📂 **[Go to Lab 03](03-self-hosted-ci-runner/)**

---

## 📜 Lab 04 - Bash Automation Toolkit

**Skills:** Production-safe scripting, automation, idempotency

### What You'll Build - Automation Scripts

- System health check script
- Safe log cleanup automation
- Idempotent user provisioning
- Cron-scheduled tasks

### Key Concepts - Bash Automation

- Production bash safety (`set -euo pipefail`)
- Input validation
- Idempotent operations
- Dry-run testing
- Error handling

### Scripts Created

```bash
scripts/
├── health_check.sh      # System monitoring
├── cleanup_logs.sh      # Safe log rotation
└── provision_user.sh    # User management
```

### Technologies Used - Bash Automation

- Bash scripting
- cron
- rsync
- System monitoring tools

📂 **[Go to Lab 04](04-bash-ops-automation-toolkit/)**

---

## 🔐 Lab 05 - Linux Security Hardening

**Skills:** DevSecOps, compliance, attack surface reduction

### What You'll Build - Security Hardening

- SSH hardening (key auth only)
- Firewall configuration (UFW)
- Intrusion prevention (fail2ban)
- Security audit checklist

### Key Concepts - Security Hardening

- SSH attack surface reduction
- Network-level access control
- Automated intrusion detection
- Security validation and evidence

### Security Measures

- ✅ Password authentication disabled
- ✅ Root login disabled
- ✅ Firewall default-deny policy
- ✅ Automated ban for brute-force attempts
- ✅ Audit evidence captured

### Technologies Used - Security Hardening

- OpenSSH
- UFW (Uncomplicated Firewall)
- fail2ban
- systemd

📂 **[Go to Lab 05](05-linux-security-hardening-devsecops/)**

---

## 🎓 Learning Progression

These labs follow a **logical DevOps journey**:

1. **Containerization** → Learn Docker fundamentals
2. **Routing** → Understand service proxying
3. **CI/CD** → Deploy automation infrastructure
4. **Scripting** → Build reusable automation tools
5. **Security** → Harden production systems

This mirrors how DevOps engineers **actually work** in real environments.

---

## 💡 Real-World Applications

### Where These Skills Are Used

| Lab | Production Use Case |
| --- | ----------------- |
| **Docker Host** | Running microservices, databases, background workers |
| **Nginx Proxy** | API gateway, load balancing, SSL termination |
| **CI Runner** | Private repos, custom build agents, on-prem pipelines |
| **Bash Scripts** | Health checks, cleanup jobs, provisioning automation |
| **Security Hardening** | Compliance requirements, PCI-DSS, SOC 2 |

---

## 🔐 Security Throughout

Every lab implements security best practices:

- ✅ Least-privilege access
- ✅ Network isolation
- ✅ Secrets management
- ✅ Audit logging
- ✅ Validation and testing

---

## 📝 Interview Readiness

Each lab includes:

- **Technical explanations** - Why decisions were made
- **Troubleshooting scenarios** - Common problems and solutions
- **Interview questions** - Real questions with talking points
- **Production considerations** - Scaling, monitoring, security

---

## Getting Started

1. **Prerequisites:**
   - Linux system (Ubuntu 20.04+ recommended)
   - sudo access
   - Basic command-line skills

2. **Pick a lab:**
   - Each lab is independent
   - Start with Docker if new to containers
   - Security hardening should be done last

3. **Follow the steps:**
   - Each lab has detailed `steps.md`
   - Screenshots validate key points
   - Cleanup guides ensure safe teardown

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Admin Guide](https://nginx.org/en/docs/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [fail2ban Documentation](https://www.fail2ban.org/)

---

## 🔗 Related Sections

- **[Linux System Administration](../linux-sysadmin/)** - Foundation skills
- **[Azure Cloud Engineering](../azure-cloud-engineer/)** - Cloud infrastructure
- **[Uptime Monitor App](../uptime-monitor/)** - Full-stack deployment

---

**These aren't tutorials. These are working implementations that demonstrate real DevOps engineering competence.**
