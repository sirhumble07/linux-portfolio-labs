# Azure Cloud Engineer Portfolio — Linux Infrastructure & Security Labs

This repository documents my **hands-on Azure Cloud Engineer portfolio**, focused on **Linux infrastructure, security, automation, networking, and monitoring**.

Every lab is:

- Built from scratch in Microsoft Azure
- Implemented using real production patterns
- Validated with Linux commands and Azure configuration
- Documented step-by-step with screenshots and evidence

This portfolio demonstrates **how Linux systems are actually deployed, secured, automated, and operated in Azure**.

---

## Core Azure Skills Demonstrated

- Azure Resource Groups & regional design (UK South)
- Secure Linux VM deployment (SSH keys only)
- Network Security Groups (NSGs) & traffic isolation
- Azure Virtual Networks & subnet segmentation
- cloud-init automation for Linux provisioning
- Azure Monitor & alerting for Linux workloads
- Incident detection and alert validation
- Zero-trust access using Azure Bastion
- Public vs private connectivity validation from Linux

---

## Azure Lab Overview

### Azure Lab 1 - Secure Linux VM Deployment & SSH Hardening

**Folder:** `azure-cloud-engineer/01-azure-linux-vm-hardening`

#### What I Built (Lab 1)

- Ubuntu Linux VM deployed in Azure (UK South)
- SSH key authentication only (no passwords)
- Root login disabled
- Network Security Group restricted to my IP
- Validation via SSH logs and failed password attempts

#### Key skills (Lab 1)

- Azure VM lifecycle
- SSH hardening
- NSG inbound security
- OS-level and cloud-level security alignment

---

### Azure Lab 2 — Azure Networking & Linux Connectivity Validation

**Folder:** `azure-cloud-engineer/02-azure-vnet-nsg-linux-connectivity`

#### What I Built (Lab 2)

- Virtual Network with isolated subnets (management & web)
- Subnet-level NSGs enforcing traffic flow
- Management VM with controlled SSH access
- Web VM accessible via HTTP only
- Proven connectivity using Linux tools

#### Key skills (Lab 2)

- VNet & subnet design
- NSG rule logic
- Public vs private traffic analysis
- Linux-based network validation

---

### Azure Lab 3 — Zero Public IP Access with Azure Bastion

**Folder:** `azure-cloud-engineer/03-azure-bastion-zero-public-ip`

#### What I Built (Lab 3)

- Linux VM with **no public IP**
- Secure admin access via Azure Bastion
- Dedicated Bastion subnet
- Proven SSH access is impossible from the internet
- Zero-trust administrative access model

#### Key skills (Lab 3)

- Azure Bastion
- Private networking
- Zero-trust architecture
- Attack surface reduction

---

### 🚨 Azure Lab 4 — Azure Monitoring & Alerts for Linux

**Folder:** `azure-cloud-engineer/04-azure-monitoring-linux-alerts`

#### What I Built (Lab 4)

- Enabled Azure Monitor for Linux VMs
- Configured metric-based alerts (CPU, disk)
- Created action groups for notifications
- Triggered alerts intentionally using stress testing
- Verified alert firing and resolution

#### Key skills (Lab 4)

- Azure Monitor
- Metrics vs logs
- Alert rules & action groups
- Proactive operations mindset

---

### Azure Lab 5 — Automated Linux Provisioning with cloud-init

**Folder:** `azure-cloud-engineer/05-cloud-init-standardized-bootstrap`

#### What I Built (Lab 5)

- Fully automated Linux VM bootstrap at first boot
- Package installation (nginx, curl)
- User creation with sudo access
- File deployment and service enablement
- Debugged provisioning using cloud-init logs

#### Key skills (Lab 5)

- cloud-init YAML
- Immutable infrastructure mindset
- Boot-time automation
- Provisioning troubleshooting

---

## How This Maps to Real Azure Roles

These labs directly reflect responsibilities in:

- Azure Cloud Engineer
- Infrastructure Engineer
- Cloud Support Engineer
- Junior–Mid DevOps Engineer (Linux-focused)

This portfolio demonstrates:

- Secure-by-default thinking
- Automation over manual configuration
- Clear validation and troubleshooting
- Documentation discipline expected in production teams

---

## What’s Next

This Azure Linux foundation will now be extended into **DevOps engineering**, including:

- Containers (Docker)
- CI/CD pipelines
- Infrastructure automation
- Application delivery
- DevOps security practices

👉 See the upcoming `devops/` folder for DevOps-focused labs.
