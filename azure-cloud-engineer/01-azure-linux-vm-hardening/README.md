# Lab 01: Azure Linux VM Deployment + SSH Hardening

## Overview

This lab demonstrates deploying a Linux VM in Azure (UK South region) and implementing SSH security hardening best practices. The focus is on securing remote access by disabling password authentication and root login while enforcing key-based authentication only.

## Objectives

- Deploy Ubuntu Linux VM in Azure with SSH key authentication
- Configure Network Security Group (NSG) to restrict SSH access
- Harden SSH configuration to prevent password-based attacks
- Validate security configuration through testing and logging

## Technologies Used

- **Azure Virtual Machines** (Ubuntu LTS)
- **Azure Network Security Groups** (NSG)
- **SSH** (OpenSSH Server)
- **systemd** (service management)
- **journalctl** (logging)

## Key Skills Demonstrated

- Azure resource provisioning (Resource Groups, VMs, NSGs)
- Linux SSH configuration and hardening
- Security best practices for remote access
- System service management and validation
- Log analysis and troubleshooting

## Architecture

- **Resource Group**: `rg-linux-hardening-uks`
- **Region**: UK South
- **VM OS**: Ubuntu LTS
- **Authentication**: SSH key-based only (password disabled)
- **Network Security**: NSG restricting SSH to specific IP addresses

## Success Criteria

✅ VM accessible via SSH key authentication  
✅ Password authentication disabled and tested (should fail)  
✅ Root login disabled  
✅ NSG rules restrict SSH access to authorized IPs only  
✅ SSH service configuration validated  
✅ Security changes logged and verifiable

## Files in This Lab

- [`steps.md`](steps.md) - Detailed step-by-step instructions
- [`ssh-hardening-notes.md`](ssh-hardening-notes.md) - SSH security configuration notes
- [`cleanup.md`](cleanup.md) - Resource cleanup instructions
- `assets/screenshots/` - Documentation screenshots

## Next Steps

After completing this lab, proceed to:

- **Lab 02**: Azure VNet & NSG with Linux Connectivity
- **Lab 03**: Azure Bastion for Zero Public IP Access
