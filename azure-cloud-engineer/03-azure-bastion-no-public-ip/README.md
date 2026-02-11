
# azure-cloud-engineer/03-azure-bastion-no-public-ip/README.md

```md
# Zero Public IP Access: Azure Bastion to Linux VM

## What you will build
- VNet with AzureBastionSubnet
- Azure Bastion
- Linux VM with NO public IP
- Admin access via Bastion

## Success criteria
- VM has no public IP resource
- You can connect via Bastion and run commands

## Zero-Trust Access Model
- VM has no public IP address
- SSH is not exposed to the internet
- All administrative access flows through Azure Bastion
- Bastion uses HTTPS (443) and Azure AD-controlled access
- This model reduces attack surface and brute-force risk
