# Cleanup Instructions — Lab 03: Azure Bastion

## Delete Resources via Azure Portal

### Option 1: Delete Resource Group (Recommended)

⚠️ **Warning**: Azure Bastion has hourly charges (~$0.19/hour or ~$140/month), so delete promptly when finished.

1. Navigate to **Resource groups** in Azure Portal
2. Select `rg-bastion-linux-uks`
3. Click **Delete resource group**
4. Type the resource group name to confirm: `rg-bastion-linux-uks`
5. Click **Delete**

**Resources deleted**:

- Azure Bastion host
- Virtual Machine (workload VM)
- Network Interface
- Virtual Network (VNet) with subnets
- OS Disk
- Public IP for Bastion
- Any associated resources

⏱️ **Time**: ~10-15 minutes for complete deletion (Bastion takes longer to delete)

---

### Option 2: Delete Bastion Only (Keep Other Resources)

If you want to delete Bastion but keep the VM and VNet:

1. Navigate to **Bastions** in Azure Portal
2. Select your Bastion resource
3. Click **Delete**
4. Confirm deletion

⚠️ **Note**: After deleting Bastion, the VM will have **no public IP** and will be inaccessible unless you:

- Add a public IP to the VM
- Use another jump box
- Deploy a new Bastion

---

## Delete Resources via Azure CLI

### Delete Entire Resource Group

```bash
az group delete --name rg-bastion-linux-uks --yes --no-wait
```

### Check Deletion Status

```bash
az group exists --name rg-bastion-linux-uks
```

Returns `false` when fully deleted.

---

### Delete Bastion Only

```bash
# List Bastion resources
az network bastion list --resource-group rg-bastion-linux-uks --output table

# Delete Bastion
az network bastion delete \
  --resource-group rg-bastion-linux-uks \
  --name <bastion-name>
```

---

### Delete Individual Resources

```bash
# List all resources
az resource list --resource-group rg-bastion-linux-uks --output table

# Delete VM
az vm delete \
  --resource-group rg-bastion-linux-uks \
  --name <vm-name> \
  --yes

# Delete VNet (also deletes subnets)
az network vnet delete \
  --resource-group rg-bastion-linux-uks \
  --name vnet-bastion

# Delete Bastion public IP (if not auto-deleted)
az network public-ip delete \
  --resource-group rg-bastion-linux-uks \
  --name <bastion-public-ip-name>
```

---

## Verify Cleanup

### Portal Verification

1. Navigate to **Bastions** - ensure your Bastion is gone
2. Check **Resource groups** - ensure `rg-bastion-linux-uks` is deleted
3. Check **All resources** - filter by "bastion" to ensure no orphaned resources

### CLI Verification

```bash
# Check if resource group exists
az group exists --name rg-bastion-linux-uks

# List all Bastion resources in subscription
az network bastion list --output table

# List resources in the group (if it still exists)
az resource list --resource-group rg-bastion-linux-uks --output table
```

---

## Cost Considerations

### Azure Bastion Pricing

⚠️ **Azure Bastion is one of the more expensive Azure services**

**Basic SKU**:

- ~$0.19/hour = ~$140/month (US pricing, varies by region)
- Charged for every hour deployed (even if not used)

**Standard SKU**:

- ~$0.19/hour base + usage-based charges
- Supports features like IP-based connections, shareable links

**Other Resources**:

- **VM**: Hourly compute charges (even when stopped, unless deallocated)
- **Disks**: Ongoing storage costs
- **VNet**: Free (except peering if configured)
- **Public IP for Bastion**: Included in Bastion cost

**To minimize costs**:

- Delete Bastion immediately after lab completion
- Use Bastion only when needed (can't easily stop/start)

---

## Alternative: Deallocate VM (Keep Bastion)

If you need to pause but keep Bastion infrastructure:

### Portal

1. Virtual machines → Select VM → **Stop**
2. Wait for status: "Stopped (deallocated)"

### CLI

```bash
az vm deallocate --resource-group rg-bastion-linux-uks --name <vm-name>
```

⚠️ **Bastion charges continue** even if VM is deallocated!

---

## Troubleshooting Cleanup Issues

### Bastion Won't Delete

**Symptoms**: Deletion takes a long time or fails

**Solutions**:

1. **Wait**: Bastion deletions can take 10-15 minutes
2. **Check dependencies**: Ensure no VMs are actively using Bastion
3. **Force delete subnet**: Sometimes the AzureBastionSubnet prevents VNet deletion

```bash
# Delete AzureBastionSubnet after Bastion is deleted
az network vnet subnet delete \
  --resource-group rg-bastion-linux-uks \
  --vnet-name vnet-bastion \
  --name AzureBastionSubnet
```

### Resource Group Won't Delete

**Cause**: Resources might be locked or have dependencies

**Solution**:

```bash
# Check for locks
az lock list --resource-group rg-bastion-linux-uks

# Delete lock if exists
az lock delete --name <lock-name> --resource-group rg-bastion-linux-uks

# Retry deletion
az group delete --name rg-bastion-linux-uks --yes
```

---

## Cleanup Checklist

- [ ] Azure Bastion deleted (or resource group deleted)
- [ ] Resource group `rg-bastion-linux-uks` deleted
- [ ] No orphaned Bastion resources in portal
- [ ] VM deleted or inaccessible (if Bastion-only access was used)
- [ ] VNet and subnets deleted
- [ ] Verify no ongoing Bastion charges in Azure Cost Management
- [ ] Check "All resources" view for any lingering resources

---

## Post-Cleanup Notes

After deleting Bastion:

- VMs without public IPs become inaccessible (as intended in this lab)
- Consider alternative access methods for production:
  - VPN Gateway
  - ExpressRoute
  - Jump box with NSG restrictions
  - Azure Bastion (for secure, scalable access)

---

## Cost Management Check

After cleanup, verify no charges:

1. Navigate to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by:
   - Resource group: `rg-bastion-linux-uks`
   - Service: "Azure Bastion", "Virtual Machines"
4. Ensure costs drop to $0 within 24 hours

If charges continue after 24 hours, investigate for orphaned resources.
