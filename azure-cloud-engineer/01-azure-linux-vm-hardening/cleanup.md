# Cleanup Instructions

## Delete Resources via Azure Portal

### Option 1: Delete Resource Group (Recommended)

This will delete all resources within the resource group at once:

1. Navigate to **Resource groups** in Azure Portal
2. Find and select `rg-linux-hardening-uks`
3. Click **Delete resource group**
4. Type the resource group name to confirm: `rg-linux-hardening-uks`
5. Click **Delete**

**Resources deleted**:

- Virtual Machine (VM)
- Network Interface (NIC)
- Public IP Address
- Virtual Network (VNet)
- Network Security Group (NSG)
- Disk(s)
- Any other associated resources

⏱️ **Time**: ~3-5 minutes for complete deletion

---

### Option 2: Delete VM Only (Keep Network Resources)

If you want to keep the VNet and NSG for other labs:

1. Navigate to **Virtual machines**
2. Select your VM
3. Click **Delete**
4. Check boxes to confirm deletion of:
   - ✅ VM
   - ✅ OS disk
   - ✅ Network interface
   - ✅ Public IP (optional)
5. Click **Delete**

---

## Delete Resources via Azure CLI

### Delete Entire Resource Group

```bash
az group delete --name rg-linux-hardening-uks --yes --no-wait
```

Options:

- `--yes`: Skips confirmation prompt
- `--no-wait`: Returns immediately (deletion continues in background)

### Check Deletion Status

```bash
az group exists --name rg-linux-hardening-uks
```

Returns `false` when fully deleted.

---

### Delete Individual VM (Keep Resource Group)

```bash
# Get VM details
az vm show --resource-group rg-linux-hardening-uks --name <vm-name>

# Delete VM and associated resources
az vm delete \
  --resource-group rg-linux-hardening-uks \
  --name <vm-name> \
  --yes

# Optionally delete public IP
az network public-ip delete \
  --resource-group rg-linux-hardening-uks \
  --name <public-ip-name>

# Optionally delete network interface
az network nic delete \
  --resource-group rg-linux-hardening-uks \
  --name <nic-name>
```

---

## Verify Cleanup

### Portal Verification

1. Check **Resource groups** - ensure `rg-linux-hardening-uks` is gone
2. Check **All resources** - filter by "hardening" to ensure no orphaned resources

### CLI Verification

```bash
# List all resource groups
az group list --output table

# List resources in the group (if it still exists)
az resource list --resource-group rg-linux-hardening-uks --output table
```

---

## Cost Considerations

⚠️ **Important**: Azure charges for:

- VM compute (hourly)
- Storage (disks)
- Public IP addresses (if static)
- Data transfer

Even if a VM is stopped (deallocated), you still pay for:

- Disks
- Static public IPs

**To avoid charges**: Delete all resources when lab is complete.

---

## Local Cleanup (Optional)

### Remove SSH Keys (if temporary)

```bash
# Remove private key
rm ~/.ssh/<private-key-name>

# Remove public key
rm ~/.ssh/<private-key-name>.pub

# Remove from SSH config if added
nano ~/.ssh/config
```

### Remove Known Hosts Entry

```bash
# Remove the VM's fingerprint from known_hosts
ssh-keygen -R <public-ip>
```

---

## Troubleshooting Cleanup Issues

### Resource Group Won't Delete

**Cause**: Resources might be locked or have dependencies

**Solution**:

```bash
# Check for locks
az lock list --resource-group rg-linux-hardening-uks

# Delete lock if exists
az lock delete --name <lock-name> --resource-group rg-linux-hardening-uks
```

### "Resource in Use" Error

**Solution**: Wait a few minutes and retry. Some resources need time to fully release.

---

## Cleanup Checklist

- [ ] Resource group `rg-linux-hardening-uks` deleted
- [ ] No orphaned resources in Azure Portal
- [ ] VM public IP no longer responds to ping/SSH
- [ ] (Optional) Local SSH keys removed
- [ ] (Optional) Known hosts entry removed
- [ ] Verify no ongoing charges in Azure Cost Management
