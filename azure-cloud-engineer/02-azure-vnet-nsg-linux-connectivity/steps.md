# Steps — Azure VNet/Subnets/NSG + Linux Connectivity Tests

## 1) Create RG

- Name: `rg-azure-networking-linux-uks`
- Region: UK South

## 2) Create VNet

- Address space: `10.10.0.0/16`
- Subnets:
  - `snet-mgmt` = `10.10.1.0/24`
  - `snet-web`  = `10.10.2.0/24`

## 3) Create NSGs

### NSG for mgmt subnet

Inbound:

- Allow SSH 22 from **My IP** to mgmt subnet
Outbound: default ok

### NSG for web subnet

Inbound:

- Allow HTTP 80 from Internet
- Deny SSH 22 from Internet (or simply do not allow it)
- Allow SSH 22 from `10.10.1.0/24` (mgmt subnet)

## 4) Deploy two VMs

- VM1 mgmt: in `snet-mgmt`, public IP ok
- VM2 web: in `snet-web`, public IP ok (for HTTP testing)

## 5) Configure a web page on web VM

SSH to web VM (via mgmt VM if needed):

```bash
sudo apt update
sudo apt -y install nginx
echo "<h1>Web subnet VM</h1>" | sudo tee /var/www/html/index.html
sudo systemctl restart nginx
```

## 6) Validate (prove allowed vs blocked)

From your laptop:

```bash
curl -I http://<web-public-ip>
ssh azureuser@<web-public-ip>
```

Expected:

- HTTP works
- SSH fails (blocked)

From mgmt VM:

```bash
ssh azureuser@<web-private-ip>
```

Expected:

- SSH works via private IP
