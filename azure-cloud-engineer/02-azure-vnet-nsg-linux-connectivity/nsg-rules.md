# NSG Rules Configuration — Lab 02

## Network Security Group (NSG) Overview

NSGs act as virtual firewalls, controlling inbound and outbound traffic at the subnet or NIC level. Rules are evaluated by **priority** (lower number = higher priority).

---

## Management Subnet NSG (`nsg-mgmt`)

### Inbound Rules

| Priority | Name | Port | Protocol | Source | Destination | Action | Purpose |
|----------|------|------|----------|--------|-------------|--------|---------|
| 100 | AllowSSHFromMyIP | 22 | TCP | My IP Address | 10.10.1.0/24 | Allow | Admin SSH access |
| 65000 | DenyAllInbound | * | * | Any | Any | Deny | Default deny rule |

### Outbound Rules

| Priority | Name | Port | Protocol | Source | Destination | Action | Purpose |
|----------|------|------|----------|--------|-------------|--------|---------|
| 65000 | AllowInternetOutbound | * | * | Any | Internet | Allow | Allow internet access |
| 65001 | AllowVNetOutbound | * | * | VirtualNetwork | VirtualNetwork | Allow | Allow VNet traffic |

**Key Points**:
- SSH is restricted to **your specific IP address only**
- All other inbound traffic is denied by default
- VMs can reach the internet and other VNet resources

---

## Web Subnet NSG (`nsg-web`)

### Inbound Rules

| Priority | Name | Port | Protocol | Source | Destination | Action | Purpose |
|----------|------|------|----------|--------|-------------|--------|---------|
| 100 | AllowHTTPFromInternet | 80 | TCP | Internet | 10.10.2.0/24 | Allow | Public web access |
| 110 | AllowSSHFromMgmt | 22 | TCP | 10.10.1.0/24 | 10.10.2.0/24 | Allow | Admin access from mgmt |
| 120 | DenySSHFromInternet | 22 | TCP | Internet | 10.10.2.0/24 | Deny | Block public SSH |
| 65000 | DenyAllInbound | * | * | Any | Any | Deny | Default deny rule |

### Outbound Rules

| Priority | Name | Port | Protocol | Source | Destination | Action | Purpose |
|----------|------|------|----------|--------|-------------|--------|---------|
| 65000 | AllowInternetOutbound | * | * | Any | Internet | Allow | Allow internet access |
| 65001 | AllowVNetOutbound | * | * | VirtualNetwork | VirtualNetwork | Allow | Allow VNet traffic |

**Key Points**:
- HTTP (port 80) is open to the **internet** for public access
- SSH from internet is **explicitly denied**
- SSH from management subnet (10.10.1.0/24) is **allowed**
- This creates a "jump box" architecture

---

## Rule Priority Best Practices

### Understanding Priority

- **Lower numbers** = **higher priority** (processed first)
- Range: 100 - 4096
- Default rules: 65000+ (lowest priority)
- Rules are processed **in order** until a match is found

### Example: Why Priority Matters

**Scenario**: Web subnet needs HTTP open, but SSH restricted

```text
Priority 100: Allow HTTP 80 from Internet → Allow
Priority 110: Allow SSH 22 from 10.10.1.0/24 → Allow
Priority 120: Deny SSH 22 from Internet → Deny
```

If priority 120 was set to 100, it would block ALL SSH including from mgmt subnet!

---

## Testing NSG Rules

### Test 1: HTTP Access (Should Work)

From your laptop:
```bash
curl http://<web-vm-public-ip>
```

**Expected**: HTML page returned (nginx default or custom page)

---

### Test 2: Direct SSH to Web VM (Should Fail)

From your laptop:
```bash
ssh azureuser@<web-vm-public-ip>
```

**Expected**: Connection timeout or "Connection refused"

---

### Test 3: SSH via Jump Box (Should Work)

From mgmt VM:
```bash
ssh azureuser@<web-vm-private-ip>
```

Or use SSH ProxyJump from your laptop:
```bash
ssh -J azureuser@<mgmt-vm-public-ip> azureuser@<web-vm-private-ip>
```

**Expected**: Successful connection

---

## NSG Rule Creation via Portal

### Create Inbound Rule

1. Navigate to **Network security groups**
2. Select your NSG (e.g., `nsg-web`)
3. Click **Inbound security rules** → **Add**
4. Configure:
   - **Source**: IP address, Service Tag, or Application security group
   - **Source port ranges**: `*` (usually)
   - **Destination**: IP address or Virtual network
   - **Destination port ranges**: e.g., `80`, `22`, `443`
   - **Protocol**: TCP, UDP, or Any
   - **Action**: Allow or Deny
   - **Priority**: 100-4096 (lower = higher priority)
   - **Name**: Descriptive name
5. Click **Add**

---

## NSG Rule Creation via CLI

### Allow HTTP from Internet

```bash
az network nsg rule create \
  --resource-group rg-azure-networking-linux-uks \
  --nsg-name nsg-web \
  --name AllowHTTPFromInternet \
  --priority 100 \
  --source-address-prefixes Internet \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.10.2.0/24 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp \
  --description "Allow HTTP traffic from internet"
```

### Allow SSH from Management Subnet

```bash
az network nsg rule create \
  --resource-group rg-azure-networking-linux-uks \
  --nsg-name nsg-web \
  --name AllowSSHFromMgmt \
  --priority 110 \
  --source-address-prefixes 10.10.1.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.10.2.0/24 \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp \
  --description "Allow SSH from management subnet"
```

### Deny SSH from Internet

```bash
az network nsg rule create \
  --resource-group rg-azure-networking-linux-uks \
  --nsg-name nsg-web \
  --name DenySSHFromInternet \
  --priority 120 \
  --source-address-prefixes Internet \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.10.2.0/24 \
  --destination-port-ranges 22 \
  --access Deny \
  --protocol Tcp \
  --description "Block SSH from internet"
```

---

## Service Tags

Service tags represent groups of IP addresses for Azure services:

- **Internet**: All public internet addresses
- **VirtualNetwork**: All addresses in the VNet
- **AzureLoadBalancer**: Azure's load balancer probe IPs
- **Storage**: Azure Storage service IPs
- **Sql**: Azure SQL Database IPs
- **AzureMonitor**: Azure Monitor IPs

**Example**: Allow only Azure services to access a resource:
```text
Source: AzureMonitor
Destination: VirtualNetwork
Port: 443
Action: Allow
```

---

## Common Patterns

### Jump Box / Bastion Pattern (Used in this Lab)

```text
Internet → mgmt VM (SSH allowed from My IP)
mgmt VM → web VM (SSH allowed from mgmt subnet)
Internet → web VM (HTTP allowed, SSH denied)
```

### DMZ Pattern

```text
Internet → DMZ subnet (HTTP/HTTPS)
DMZ → Internal subnet (App tier)
Internal → Data subnet (Database)
```

---

## Troubleshooting NSG Issues

### Problem: Can't SSH to VM

**Check**:
1. NSG has Allow rule for SSH (port 22)
2. Rule priority is correct (not blocked by higher-priority deny)
3. Source IP is correct (check your current IP with `curl ifconfig.me`)
4. VM is running and has a public IP
5. OS firewall (ufw/iptables) isn't blocking

### Problem: Web traffic not reaching VM

**Check**:
1. NSG allows port 80/443
2. Web server is running (`systemctl status nginx`)
3. Web server is listening on correct port (`ss -tuln | grep :80`)
4. VM has public IP and is accessible

### View Effective Security Rules

Portal: VM → Networking → Network Interface → Effective security rules

CLI:
```bash
az network nic list-effective-nsg \
  --resource-group rg-azure-networking-linux-uks \
  --name <nic-name>
```

---

## Security Best Practices

✅ **Do**:
- Use specific IP ranges instead of "Any" when possible
- Document the purpose of each rule
- Regularly review and remove unused rules
- Use service tags for Azure services
- Implement least privilege (deny by default)

❌ **Don't**:
- Allow SSH (22) from `0.0.0.0/0` (Internet) in production
- Use priority conflicts (rules that contradict each other)
- Leave default "Allow All" rules in production
- Forget to test rules after changes
- Mix subnet-level and NIC-level NSGs without clear documentation

---

## Defense in Depth

NSGs are **one layer** of security. Complete defense requires:

1. **Network Layer**: NSGs, Azure Firewall
2. **Identity Layer**: Azure AD, MFA
3. **Application Layer**: SSH hardening, TLS/HTTPS
4. **Data Layer**: Encryption at rest and in transit
5. **Monitoring**: Azure Monitor, Log Analytics

This lab focuses on **network layer** security with NSGs.
