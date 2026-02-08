# Steps — Standardized Linux Bootstrap with cloud-init

## 1) Create RG + VM

Create a new VM (clean proof):

- `rg-cloudinit-linux-uks`
- Region UK South
- Auth: SSH key

## 2) Add cloud-init

In VM creation → Advanced → Custom data (cloud-init), paste:

```yaml
#cloud-config
package_update: true
packages:
  - nginx
  - curl

users:
  - name: labuser
    groups: sudo
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"

write_files:
  - path: /var/www/html/index.html
    permissions: "0644"
    content: |
      <h1>Azure cloud-init lab</h1>

runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
```

## 3) Validate on the VM

SSH in:

```bash
nginx -v
systemctl is-active nginx
cat /var/www/html/index.html
```

Check cloud-init logs:

```bash
sudo tail -n 200 /var/log/cloud-init.log
sudo tail -n 200 /var/log/cloud-init-output.log
```

## 4) Validate from your laptop

```bash
curl -I http://<vm-public-ip>
```
