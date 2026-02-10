# Azure Networking Lab: VNet/Subnets/NSG + Linux Connectivity Tests

## What you will build

- VNet + 2 subnets (mgmt + web)
- NSGs enforcing traffic separation
- Two Linux VMs
- Proof of allowed vs blocked traffic

## Success criteria

- web VM serves HTTP
- web VM does NOT allow SSH from internet
- mgmt VM can SSH to web VM via private IP

## Security Model

- NSGs enforce traffic before it reaches the VM
- Web VM does not accept SSH from the internet
- Management access is isolated to a dedicated subnet
- Linux firewall is secondary; Azure NSGs are primary
