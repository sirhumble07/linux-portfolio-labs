# Cleanup Instructions — Lab 02: Azure VNet/NSG + Linux Connectivity

## Delete Resources via Azure Portal

### Option 1: Delete Resource Group (Recommended)

1. Navigate to **Resource groups** in Azure Portal
2. Select `rg-azure-networking-linux-uks`
3. Click **Delete resource group**
4. Type the resource group name to confirm: `rg-azure-networking-linux-uks`
5. Click **Delete**

**Resources deleted**:

- 2 Virtual Machines (mgmt VM, web VM)
- 2 Network Interfaces
- 2 Public IP Addresses
- Virtual Network (VNet) with subnets
- 2 Network Security Groups (mgmt NSG, web NSG)
- OS Disks for both VMs
- Any associated storage resources

⏱️ **Time**: ~5-10 minutes for complete deletion

---

### Option 2: Delete Individual Resources

If you want to keep the networking infrastructure for other labs:

**Delete VMs:**

1. Virtual machines → Select each VM → Delete
2. Confirm deletion of associated disks, NICs, and public IPs

**Delete NSGs (if needed):**

1. Network security groups → Select each NSG → Delete

**Delete VNet (if needed):**

1. Virtual networks → Select VNet → Delete

---

## Delete Resources via Azure CLI

### Delete Entire Resource Group

```bash
az group delete --name rg-azure-networking-linux-uks --yes --no-wait
```

### Check Deletion Status

```bash
az group exists --name rg-azure-networking-linux-uks
```

Returns `false` when fully deleted.

---

### Delete Individual Resources

```bash
# List all resources in the group
az resource list --resource-group rg-azure-networking-linux-uks --output table

# Delete specific VMs
az vm delete --resource-group rg-azure-networking-linux-uks --name <mgmt-vm-name> --yes
az vm delete --resource-group rg-azure-networking-linux-uks --name <web-vm-name> --yes

# Delete NSGs
az network nsg delete --resource-group rg-azure-networking-linux-uks --name <mgmt-nsg-name>
az network nsg delete --resource-group rg-azure-networking-linux-uks --name <web-nsg-name>

# Delete VNet (deletes subnets too)
az network vnet delete --resource-group rg-azure-networking-linux-uks --name <vnet-name>

# Delete public IPs
az network public-ip delete --resource-group rg-azure-networking-linux-uks --name <mgmt-public-ip>
az network public-ip delete --resource-group rg-azure-networking-linux-uks --name <web-public-ip>
```

---

## Verify Cleanup

### Portal Verification

1. Check **Resource groups** - ensure `rg-azure-networking-linux-uks` is gone
2. Check **All resources** - filter by "networking" or "linux" to ensure no orphaned resources

### CLI Verification

```bash
# List all resource groups
az group list --output table | grep networking

# List resources in the group (if it still exists)
az resource list --resource-group rg-azure-networking-linux-uks --output table
```

---

## Cost Considerations

⚠️ **Resources that incur charges**:

- **VMs**: Charged hourly even when stopped (unless deallocated)
- **Disks**: Storage costs continue even if VM is deallocated
- **Public IP addresses**: Charged if static, or if dynamic but attached
- **VNet/Subnets**: Generally free (small charge for peering if configured)
- **NSGs**: Free
- **Data transfer**: Outbound data transfer charges may apply

**To minimize costs**: Delete all resources when lab is complete, especially VMs and their associated disks.

---

## Deallocate VMs (Alternative to Deletion)

If you want to pause the lab without deleting resources:

### Portal

1. Virtual machines → Select VM → Stop
2. Wait for status to show "Stopped (deallocated)"

### CLI

```bash
az vm deallocate --resource-group rg-azure-networking-linux-uks --name <vm-name>
```

**Note**: You still pay for disks and static public IPs when deallocated.

---

## Cleanup Checklist

- [ ] Resource group `rg-azure-networking-linux-uks` deleted
- [ ] No orphaned resources in Azure Portal
- [ ] Both VM public IPs no longer respond to ping/SSH
- [ ] Web VM no longer serves HTTP content
- [ ] Verify no ongoing charges in Azure Cost Management
- [ ] (Optional) Remove SSH known_hosts entries for VM IPs

```bash
# Remove known_hosts entries
ssh-keygen -R <mgmt-vm-public-ip>
ssh-keygen -R <web-vm-public-ip>
```
