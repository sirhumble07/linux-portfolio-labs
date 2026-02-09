# Azure Bastion Architecture Notes

## What is Azure Bastion?

Azure Bastion is a fully managed PaaS service that provides secure RDP and SSH connectivity to virtual machines **directly through the Azure Portal** without exposing VMs via public IP addresses.

### Key Characteristics

- **Managed Service**: Microsoft manages the infrastructure (no patching, no scaling concerns)
- **Built-in Security**: No need for public IPs on target VMs
- **Browser-Based**: Access VMs directly from Azure Portal (HTML5)
- **Protocol Support**: RDP (port 3389) and SSH (port 22)
- **Encrypted**: TLS connection from browser to Bastion, then RDP/SSH to VM

---

## Architecture Overview

```text
┌──────────────────────────────────────────────────────────┐
│  Your Laptop/Browser (HTTPS/TLS)                         │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ Port 443 (HTTPS/TLS)
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│  Azure Portal (Portal.azure.com)                         │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ TLS Connection
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│  Azure Bastion Service (PaaS)                            │
│  - Deployed in AzureBastionSubnet                        │
│  - Public IP attached to Bastion (not VM)                │
│  - Managed by Microsoft                                  │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ Private IP (SSH/RDP)
                     │ Within VNet
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│  Target VM(s) in Workload Subnet                         │
│  - No public IP needed                                   │
│  - Accessed via private IP only                          │
│  - SSH (22) or RDP (3389)                                │
└──────────────────────────────────────────────────────────┘
```

---

## Network Requirements

### 1. VNet and Subnets

- **VNet**: Any address space (e.g., `10.20.0.0/16`)
- **AzureBastionSubnet**:
  - **Name must be exactly**: `AzureBastionSubnet` (case-sensitive)
  - **Minimum size**: `/27` (32 addresses, but Azure reserves 5)
  - **Recommended**: `/26` (64 addresses) or larger for scalability
  - **Example**: `10.20.0.0/26`

- **Workload Subnet**: Any name and size
  - Example: `snet-workload` = `10.20.1.0/24`
  - This is where your VMs reside

### 2. Public IP for Bastion

- Bastion **requires a public IP** (standard SKU)
- This IP is attached to the Bastion service, **not the target VMs**
- Target VMs can have **no public IP** at all

### 3. NSG Requirements

- **AzureBastionSubnet**:
  - Inbound: Allow 443 from Internet (for portal connection)
  - Inbound: Allow 443, 4443 from GatewayManager service tag
  - Outbound: Allow 22, 3389 to VirtualNetwork (SSH/RDP to VMs)
  - Outbound: Allow 443 to AzureCloud service tag

- **Workload Subnet** (where VMs are):
  - Inbound: Allow 22 (SSH) or 3389 (RDP) from AzureBastionSubnet
  - No need to allow from Internet

---

## Bastion SKUs

### Basic SKU

- **Features**:
  - Connect to VMs in the same VNet
  - Up to 25 concurrent sessions (25 simultaneous users)
  - SSH and RDP support
  - Browser-based (HTML5)

- **Pricing**: ~$0.19/hour (~$140/month, varies by region)

### Standard SKU

- **All Basic features, plus**:
  - **IP-based connection**: Connect to VMs in peered VNets or on-premises
  - **Shareable links**: Generate URLs for VM access (temp access)
  - **Session recording**: Audit trail for compliance
  - **Native client support**: Use native RDP/SSH clients
  - Up to 50 concurrent sessions

- **Pricing**: ~$0.19/hour + usage-based charges

---

## How Bastion Connectivity Works

### Step-by-Step Flow

1. **User navigates to Azure Portal** → Virtual machines → Select VM → Connect → Bastion
2. **Portal establishes HTTPS/TLS connection** to Bastion service (port 443)
3. **Bastion service** (in AzureBastionSubnet) initiates connection to VM's **private IP**
4. **VM responds** over private network (no public internet exposure)
5. **Portal renders** the SSH/RDP session in browser (HTML5)

### Security Benefits

- VM has **no public IP** → Not visible to internet scanners
- No need to manage NSG rules for public SSH/RDP access
- Centralized access point → Easier to audit and monitor
- TLS encryption from browser to Bastion
- Bastion-to-VM traffic stays within VNet (private)

---

## Comparison: Bastion vs Traditional Access Methods

| Feature | Public IP + NSG | Jump Box | Azure Bastion |
| ------- | --------------- | -------- | ------------- |
| **VM Public IP Required** | Yes | Yes (for jump box) | No |
| **Management Overhead** | Medium | High (patch, secure) | Low (fully managed) |
| **Cost** | Low ($4-5/month for static IP) | Medium (VM costs) | High (~$140/month) |
| **Security** | Manual NSG rules | Jump box is attack surface | Built-in best practices |
| **Scalability** | Manual | Limited | Auto-scales |
| **Browser-Based** | No | No | Yes |
| **Audit/Logging** | Manual | Manual | Built-in (Standard SKU) |

---

## Use Cases

### When to Use Azure Bastion

✅ **Good for**:

- Production environments requiring zero public IP exposure
- Organizations with compliance requirements (no internet-facing VMs)
- Temporary admin access without VPN infrastructure
- Multi-user environments needing centralized access control
- Demos and labs where browser-based access is preferred

❌ **Not ideal for**:

- Cost-sensitive labs or dev environments (use jump box or VPN instead)
- Frequent, long-duration SSH/RDP sessions (Standard SKU helps)
- Organizations already using VPN or ExpressRoute

### When to Use Alternatives

- **VPN Gateway**: For long-term, always-on private network access
- **Jump Box**: Lower cost, more flexible, but requires manual management
- **Public IP + NSG**: Lowest cost, acceptable for dev/test (not production)
- **ExpressRoute**: For enterprise hybrid connectivity

---

## Bastion + NSG Configuration Example

### AzureBastionSubnet NSG

**Inbound**:

```text
Priority 100: Allow 443 from Internet (user access via portal)
Priority 110: Allow 443, 4443 from GatewayManager
Priority 120: Allow 8080 from VirtualNetwork (Bastion internal)
```

**Outbound**:

```text
Priority 100: Allow 22, 3389 to VirtualNetwork (SSH/RDP to VMs)
Priority 110: Allow 443 to AzureCloud (Bastion telemetry)
Priority 120: Allow 80, 443 to Internet (Bastion certificate validation)
```

### Workload Subnet NSG

**Inbound**:

```text
Priority 100: Allow 22 from AzureBastionSubnet (SSH from Bastion)
Priority 110: Deny 22 from Internet (no direct SSH)
```

**Outbound**:

```text
Default rules (allow VNet, Internet)
```

---

## Limitations and Considerations

### Limitations

- **Cost**: ~$140/month (expensive for small deployments)
- **Concurrent sessions**: 25 (Basic) or 50 (Standard)
- **No native client**: Basic SKU requires browser (Standard supports native clients)
- **Single VNet**: Basic SKU only connects to VMs in the same VNet
- **No copy/paste**: Basic SKU has clipboard limitations (Standard fixes this)
- **Latency**: Extra hop through Bastion (usually negligible)

### Best Practices

✅ Deploy in a **dedicated management VNet** (hub VNet in hub-spoke model)  
✅ Use **VNet peering** to access VMs in multiple VNets (Standard SKU)  
✅ Enable **diagnostics logs** for audit and compliance  
✅ Use **Just-In-Time (JIT) access** with Azure Security Center for additional security  
✅ Combine with **Azure AD authentication** for identity-based access  
✅ Deploy **Zone-redundant** Bastion for high availability (Standard SKU)  

---

## Bastion in Enterprise Hub-Spoke Architecture

```text
        ┌─────────────────────────┐
        │     Hub VNet            │
        │  - Azure Bastion        │
        │  - Azure Firewall       │
        │  - VPN Gateway          │
        └────────┬────────────────┘
                 │
        ┌────────┴────────┐
        │ VNet Peering    │
        └────────┬────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
┌───▼──────┐         ┌────▼──────┐
│ Spoke 1  │         │ Spoke 2   │
│ (Prod)   │         │ (Dev)     │
│ VMs here │         │ VMs here  │
└──────────┘         └───────────┘
```

**Benefits**:

- Single Bastion instance serves multiple VNets
- Centralized access management
- Lower overall cost (one Bastion vs. one per VNet)

---

## Alternative: Bastion Developer SKU (Preview)

⚠️ **Note**: As of early 2024, Microsoft is testing a lower-cost "Developer" SKU

- **Target**: Dev/test environments
- **Pricing**: Significantly lower (details TBD)
- **Limitations**: Fewer concurrent sessions, no SLA

Check Azure documentation for availability in your region.

---

## Deployment Checklist

- [ ] VNet created with at least 2 subnets
- [ ] `AzureBastionSubnet` created (minimum `/27`)
- [ ] NSG rules configured for AzureBastionSubnet
- [ ] Public IP (Standard SKU) created for Bastion
- [ ] Azure Bastion deployed and attached to VNet
- [ ] VM(s) deployed with **no public IP**
- [ ] NSG on workload subnet allows SSH/RDP from AzureBastionSubnet
- [ ] Test connectivity via Portal → VM → Connect → Bastion

---

## Monitoring and Diagnostics

### Enable Diagnostic Logs

```bash
az monitor diagnostic-settings create \
  --name bastion-logs \
  --resource <bastion-resource-id> \
  --logs '[{"category":"BastionAuditLogs","enabled":true}]' \
  --workspace <log-analytics-workspace-id>
```

### Key Metrics

- **Session count**: Number of active connections
- **Data processed**: Bandwidth usage
- **Failed connections**: Authentication or network failures

### Logs

- **BastionAuditLogs**: Who connected, when, to which VM
- **Resource health**: Bastion service availability

---

## Summary

Azure Bastion provides a **secure, managed, zero-public-IP** solution for VM access. It's ideal for production environments with compliance requirements, but comes at a higher cost. For labs and dev environments, consider using jump boxes or VPN for cost savings.

**Key Takeaway**: Bastion **eliminates public IPs on VMs** while providing centralized, auditable, browser-based access-perfect for zero-trust security models.
