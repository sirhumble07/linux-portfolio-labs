
# AZURE CLOUD ENGINEER LABS

> These labs are written for **Azure Portal** execution. Where CLI helps, it’s optional.

---

## azure-cloud-engineer/01-azure-linux-vm-hardening/README.md

```md
# Azure Linux VM Deployment + SSH Hardening (UK South)

## What you will build
An Ubuntu VM in Azure with:
- SSH key authentication
- password login disabled
- root login disabled
- NSG inbound restricted

## Why it matters
This is baseline cloud security. Most orgs will reject “SSH open to the world”.

## Success criteria
- SSH key login works
- password auth fails
- NSG inbound is restricted (ideally your IP only)
