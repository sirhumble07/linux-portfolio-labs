# Cleanup Instructions — Lab 04: Azure Monitoring + Alerts

## Delete Resources via Azure Portal

### Option 1: Delete Resource Group (Recommended)

1. Navigate to **Resource groups** in Azure Portal
2. Select `rg-monitoring-linux-uks`
3. Click **Delete resource group**
4. Type the resource group name to confirm: `rg-monitoring-linux-uks`
5. Click **Delete**

**Resources deleted**:

- Virtual Machine
- Network Interface
- Public IP Address
- Virtual Network
- Network Security Group
- OS Disk
- Monitoring agents and extensions
- Any associated storage resources

⏱️ **Time**: ~3-5 minutes for complete deletion

---

### Option 2: Keep VM, Remove Only Monitoring

If you want to keep the VM but remove monitoring:

1. **Disable VM Insights**:
   - VM → Monitoring → Insights → Disable

2. **Delete Alert Rules**:
   - Azure Monitor → Alerts → Alert rules
   - Select each rule → Delete

3. **Delete Action Groups**:
   - Azure Monitor → Alerts → Action groups
   - Select `ag-linux-alerts` → Delete

4. **Remove Extensions** (optional):
   - VM → Extensions + applications
   - Remove monitoring agents if no longer needed

---

## Delete Resources via Azure CLI

### Delete Entire Resource Group

```bash
az group delete --name rg-monitoring-linux-uks --yes --no-wait
```

### Check Deletion Status

```bash
az group exists --name rg-monitoring-linux-uks
```

Returns `false` when fully deleted.

---

### Delete Alert Rules Only

```bash
# List all alert rules in resource group
az monitor metrics alert list \
  --resource-group rg-monitoring-linux-uks \
  --output table

# Delete specific alert rule
az monitor metrics alert delete \
  --resource-group rg-monitoring-linux-uks \
  --name <alert-rule-name>
```

---

### Delete Action Groups

```bash
# List action groups
az monitor action-group list \
  --resource-group rg-monitoring-linux-uks \
  --output table

# Delete action group
az monitor action-group delete \
  --resource-group rg-monitoring-linux-uks \
  --name ag-linux-alerts
```

---

### Delete VM and Associated Resources

```bash
# Delete VM
az vm delete \
  --resource-group rg-monitoring-linux-uks \
  --name <vm-name> \
  --yes

# Delete public IP
az network public-ip delete \
  --resource-group rg-monitoring-linux-uks \
  --name <public-ip-name>

# Delete NIC
az network nic delete \
  --resource-group rg-monitoring-linux-uks \
  --name <nic-name>

# Delete NSG
az network nsg delete \
  --resource-group rg-monitoring-linux-uks \
  --name <nsg-name>

# Delete VNet
az network vnet delete \
  --resource-group rg-monitoring-linux-uks \
  --name <vnet-name>
```

---

## Verify Cleanup

### Portal Verification

1. **Resource Groups**: Ensure `rg-monitoring-linux-uks` is gone
2. **Azure Monitor** → Alerts → Alert rules: Ensure your rules are deleted
3. **Azure Monitor** → Alerts → Action groups: Ensure `ag-linux-alerts` is deleted
4. **Virtual machines**: Ensure VM no longer appears
5. **All resources**: Filter by "monitoring" to check for orphaned resources

### CLI Verification

```bash
# Check resource group
az group exists --name rg-monitoring-linux-uks

# List alert rules (should be empty or not include your rules)
az monitor metrics alert list --output table | grep monitoring

# List action groups (should not include ag-linux-alerts)
az monitor action-group list --output table | grep ag-linux-alerts

# List resources in the group (if it still exists)
az resource list --resource-group rg-monitoring-linux-uks --output table
```

---

## Clean Up Email Alerts

If you received email notifications during the lab:

1. **Check your email inbox** for alert emails from Azure
2. **Verify unsubscribe**: When action group is deleted, you won't receive more emails
3. **Optional**: Add `noreply@email.azure.com` to contacts if you want to keep alert history

---

## Delete Log Analytics Workspace (If Created)

If you created a Log Analytics workspace for this lab:

### Portal

1. Navigate to **Log Analytics workspaces**
2. Select your workspace
3. Click **Delete**
4. Confirm deletion

### CLI

```bash
az monitor log-analytics workspace delete \
  --resource-group rg-monitoring-linux-uks \
  --workspace-name <workspace-name> \
  --yes
```

⚠️ **Note**: Deleted workspaces enter a "soft delete" state for 14 days, during which the name is reserved.

---

## Cost Considerations

### Monitoring Costs

- **VM**: Standard compute and storage charges
- **Azure Monitor Metrics**: First 10 metrics per VM are free
- **Alert Rules**:
  - First 10 metric alerts are free
  - $0.10/month per alert rule after that
- **Action Groups**: Free
- **Email Notifications**: Free
- **Log Analytics** (if used):
  - First 5GB/month free
  - $2.76/GB after that
- **VM Insights**: Data ingestion charges apply (per GB)

**To avoid charges**: Delete all resources when lab is complete, especially:

- VMs and disks
- Alert rules (beyond free tier)
- Log Analytics workspace (if created)

---

## Troubleshooting Cleanup Issues

### Alert Rules Won't Delete

**Cause**: May be in fired state or have dependencies

**Solution**:

1. Wait a few minutes for alerts to resolve
2. Disable alert rule before deletion:

   ```bash
   az monitor metrics alert update \
     --resource-group rg-monitoring-linux-uks \
     --name <alert-name> \
     --enabled false
   ```

3. Then delete:

   ```bash
   az monitor metrics alert delete \
     --resource-group rg-monitoring-linux-uks \
     --name <alert-name>
   ```

### Action Group Still Receiving Notifications

**Cause**: Action group not fully deleted or cached

**Solution**:

1. Verify deletion in portal: Azure Monitor → Action groups
2. Check email for unsubscribe link if notifications continue
3. Wait 5-10 minutes for changes to propagate

### Resource Group Won't Delete

**Cause**: Locks or dependencies

**Solution**:

```bash
# Check for locks
az lock list --resource-group rg-monitoring-linux-uks

# Delete lock if exists
az lock delete --name <lock-name> --resource-group rg-monitoring-linux-uks

# Retry deletion
az group delete --name rg-monitoring-linux-uks --yes
```

---

## Cleanup Checklist

- [ ] Resource group `rg-monitoring-linux-uks` deleted
- [ ] Alert rules deleted (CPU alert, disk alert)
- [ ] Action group `ag-linux-alerts` deleted
- [ ] VM and associated resources deleted
- [ ] No more email alerts being received
- [ ] Log Analytics workspace deleted (if created)
- [ ] No orphaned resources in "All resources" view
- [ ] Verify no ongoing charges in Azure Cost Management

---

## Verify No Active Alerts

Before final cleanup, check for any active/fired alerts:

### Portal Check for Active Alerts

1. Azure Monitor → Alerts
2. Filter: **State = Fired** or **New**
3. Ensure no alerts related to your lab

### CLI Check for Active Alerts

```bash
# List all fired alerts
az monitor metrics alert list \
  --resource-group rg-monitoring-linux-uks \
  --query "[?enabled==\`true\`]" \
  --output table
```

---

## Post-Cleanup Notes

### Learning Recap

From this lab, you learned to:

- Enable Azure Monitor VM Insights
- Create metric-based alert rules
- Configure action groups for notifications
- Trigger alerts using stress testing
- Analyze alert states and logs

### Reusable Patterns

In production, consider:

- **Centralized monitoring**: Use a dedicated Log Analytics workspace
- **Alert best practices**: Set thresholds based on baseline metrics
- **Action group reuse**: Create shared action groups for teams
- **Autoscaling**: Combine alerts with auto-scaling rules
- **Runbook automation**: Use Azure Automation for automated remediation

---

## Cost Management Check

After cleanup, verify no charges:

1. Navigate to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by:
   - Resource group: `rg-monitoring-linux-uks`
   - Service: "Virtual Machines", "Azure Monitor"
4. Ensure costs drop to $0 within 24 hours

If charges continue, look for:

- Orphaned disks
- Log Analytics workspace
- Unused alert rules
- Other resources not deleted
