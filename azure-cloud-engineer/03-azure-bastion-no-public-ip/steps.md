# Steps — Azure Bastion to Linux VM (No Public IP)

## 1) Create RG

`rg-bastion-linux-uks` in UK South

## 2) Create VNet with required subnet

- VNet: `vnet-bastion`
- Subnets:
  - `AzureBastionSubnet` (must be exact name) e.g. `10.20.0.0/26`
  - `snet-workload` e.g. `10.20.1.0/24`

## 3) Create Bastion

- Bastion → Create
- Attach to the VNet
- This will deploy the Bastion host

## 4) Create Linux VM (NO public IP)

- NIC: ensure **Public IP = None**
- Place it in `snet-workload`

## 5) Connect using Bastion

- VM → Connect → Bastion
- Authenticate (SSH key recommended)

## 6) Validate

- VM → Networking: confirm no public IP exists
- In Bastion session:

```bash
uname -a
ip a
sudo apt update
```
