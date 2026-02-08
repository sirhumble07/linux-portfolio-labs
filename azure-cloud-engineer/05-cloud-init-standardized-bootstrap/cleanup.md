# Cleanup Instructions — Lab 05: cloud-init Bootstrap

## Delete Resources via Azure Portal

### Option 1: Delete Resource Group (Recommended)

1. Navigate to **Resource groups** in Azure Portal
2. Select `rg-cloudinit-linux-uks`
3. Click **Delete resource group**
4. Type the resource group name to confirm: `rg-cloudinit-linux-uks`
5. Click **Delete**

**Resources deleted**:

- Virtual Machine (bootstrapped with cloud-init)
- Network Interface
- Public IP Address
- Virtual Network
- Network Security Group
- OS Disk
- Any cloud-init generated files/configs

⏱️ **Time**: ~3-5 minutes for complete deletion

---

### Option 2: Delete VM Only

If you want to keep the networking infrastructure:

1. Navigate to **Virtual machines**
2. Select your VM
3. Click **Delete**
4. Confirm deletion of:
   - ✅ VM
   - ✅ OS disk
   - ✅ Network interface
   - ✅ Public IP (optional)
5. Click **Delete**

---

## Delete Resources via Azure CLI

### Delete Entire Resource Group

```bash
az group delete --name rg-cloudinit-linux-uks --yes --no-wait
```

### Check Deletion Status

```bash
az group exists --name rg-cloudinit-linux-uks
```

Returns `false` when fully deleted.

---

### Delete Individual VM

```bash
# Get VM details
az vm show --resource-group rg-cloudinit-linux-uks --name <vm-name>

# Delete VM and associated resources
az vm delete \
  --resource-group rg-cloudinit-linux-uks \
  --name <vm-name> \
  --yes

# Optionally delete public IP
az network public-ip delete \
  --resource-group rg-cloudinit-linux-uks \
  --name <public-ip-name>

# Optionally delete NIC
az network nic delete \
  --resource-group rg-cloudinit-linux-uks \
  --name <nic-name>
```

---

## Verify Cleanup

### Portal Verification

1. Check **Resource groups** - ensure `rg-cloudinit-linux-uks` is gone
2. Check **Virtual machines** - ensure VM is deleted
3. Check **All resources** - filter by "cloudinit" to ensure no orphaned resources

### CLI Verification

```bash
# List all resource groups
az group list --output table | grep cloudinit

# List resources in the group (if it still exists)
az resource list --resource-group rg-cloudinit-linux-uks --output table
```

---

## Verify cloud-init Cleanup

Since cloud-init runs at VM creation and modifies the VM:

✅ **No persistent state outside VM**: cloud-init configurations exist only on the VM  
✅ **Deleting VM removes everything**: All cloud-init effects are erased  
✅ **No separate billing**: cloud-init is free (part of Ubuntu/cloud images)  

### What cloud-init Created (Now Deleted with VM)

- nginx package and service
- `/var/www/html/index.html` file
- `labuser` user account
- cloud-init logs (`/var/log/cloud-init*.log`)

---

## Cost Considerations

### Resources and Costs

- **VM**: Standard compute charges (hourly)
- **Disk**: Storage costs for OS disk
- **Public IP**: Small charge if static ($3-5/month)
- **VNet/NSG**: Generally free
- **cloud-init**: Free (no additional cost)

**To avoid charges**: Delete all resources when lab is complete.

---

## Local Cleanup (Optional)

### Remove SSH Keys (if temporary)

```bash
# Remove private key
rm ~/.ssh/<private-key-name>

# Remove public key
rm ~/.ssh/<private-key-name>.pub
```

### Remove Known Hosts Entry

```bash
# Remove the VM's fingerprint from known_hosts
ssh-keygen -R <vm-public-ip>
```

### Delete cloud-init YAML File (if saved locally)

```bash
# If you saved cloud-init.yml locally for reference
rm ~/cloud-init.yml
```

---

## Troubleshooting Cleanup Issues

### Resource Group Won't Delete

**Cause**: Resources might be locked or have dependencies

**Solution**:
```bash
# Check for locks
az lock list --resource-group rg-cloudinit-linux-uks

# Delete lock if exists
az lock delete --name <lock-name> --resource-group rg-cloudinit-linux-uks

# Retry deletion
az group delete --name rg-cloudinit-linux-uks --yes
```

### VM Still Billing After Deletion

**Cause**: Orphaned disk or public IP not deleted

**Solution**:
```bash
# List all disks
az disk list --resource-group rg-cloudinit-linux-uks --output table

# Delete orphaned disks
az disk delete --resource-group rg-cloudinit-linux-uks --name <disk-name> --yes

# List public IPs
az network public-ip list --resource-group rg-cloudinit-linux-uks --output table

# Delete public IPs
az network public-ip delete --resource-group rg-cloudinit-linux-uks --name <ip-name>
```

---

## Cleanup Checklist

- [ ] Resource group `rg-cloudinit-linux-uks` deleted
- [ ] VM no longer responds to SSH or HTTP
- [ ] No orphaned resources in Azure Portal (check "All resources")
- [ ] Verify no ongoing charges in Azure Cost Management
- [ ] (Optional) Local SSH keys removed
- [ ] (Optional) Known hosts entry removed
- [ ] (Optional) Local cloud-init.yml file removed

---

## Verify No Ongoing Charges

After cleanup, verify no charges:

1. Navigate to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by:
   - Resource group: `rg-cloudinit-linux-uks`
   - Service: "Virtual Machines"
4. Ensure costs drop to $0 within 24 hours

---

## Re-Running the Lab

If you want to re-run this lab with a fresh VM:

1. **Create new resource group**: Use a new RG or reuse the name after 24 hours
2. **Use the same cloud-init.yml**: The YAML is reusable
3. **Test different configurations**: Try adding:
   - Different packages
   - Additional users
   - Custom systemd services
   - SSH keys for multiple users

### Example: Enhanced cloud-init for Re-Run

```yaml
#cloud-config
package_update: true
packages:
  - nginx
  - curl
  - htop
  - git

users:
  - name: labuser
    groups: sudo
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
  - name: devuser
    groups: sudo
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"

write_files:
  - path: /var/www/html/index.html
    permissions: "0644"
    content: |
      <h1>Azure cloud-init lab - Enhanced</h1>
      <p>This VM was bootstrapped with cloud-init!</p>
  - path: /etc/motd
    permissions: "0644"
    content: |
      Welcome to the cloud-init lab VM!
      Provisioned automatically on boot.

runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
  - echo "cloud-init completed at $(date)" >> /var/log/bootstrap.log
```

---

## Learning Recap

From this lab, you learned:

✅ **cloud-init basics**: Automate VM configuration at boot  
✅ **Package installation**: Install packages without SSH  
✅ **User creation**: Create users with sudo access  
✅ **File management**: Write files to the filesystem  
✅ **Service management**: Enable and start services  
✅ **Validation**: Check cloud-init logs for troubleshooting  

### Next Steps

- Explore advanced cloud-init: SSH key injection, disk formatting, custom scripts
- Use cloud-init with **VM Scale Sets** for auto-scaling
- Combine cloud-init with **Azure Resource Manager (ARM) templates**
- Integrate with **Ansible** or **Terraform** for full IaC

---

## Production Considerations

In production, cloud-init can be used for:

- **Standardized VM bootstrapping**: Ensure all VMs have baseline config
- **Security hardening**: Apply security settings on first boot
- **Configuration management integration**: Install and configure agents (Ansible, Puppet, Chef)
- **Monitoring agent deployment**: Install Azure Monitor, Datadog, etc.
- **Application deployment**: Install and start applications automatically

**Best Practice**: Store cloud-init configs in version control (Git) for reproducibility.

---

## Cost Management Check

After cleanup, verify no charges:

```bash
# Check for any remaining resources in the subscription
az resource list --query "[?resourceGroup=='rg-cloudinit-linux-uks']" --output table
```

If any resources remain, delete them individually to avoid charges.
