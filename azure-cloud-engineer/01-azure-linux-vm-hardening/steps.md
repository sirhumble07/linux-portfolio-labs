# Steps — Azure Linux VM Deployment + SSH Hardening (UK South)

## 1) Create resource group (Portal)

- Resource groups → Create
- Name: `rg-linux-hardening-uks`
- Region: **UK South**

## 2) Create VM (Portal)

- Virtual machines → Create
- Image: Ubuntu LTS
- Auth: **SSH public key**
- Public inbound ports: **Allow selected ports**
- Select: **SSH (22)** temporarily (we will restrict via NSG)

## 3) Restrict NSG inbound

- Go to VM → Networking
- Inbound rules:
  - Keep SSH allowed but restrict Source to **My IP** (if stable)
  - Remove/avoid `Any` → `Any`

## 4) SSH into the VM

From your laptop:

```bash
ssh -i <path-to-private-key> azureuser@<public-ip>
```

## 5) Harden SSH on Linux

Validate config BEFORE restarting:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo nano /etc/ssh/sshd_config
```

Set:

```text
PasswordAuthentication no
PermitRootLogin no
```

Validate and restart:

```bash
sudo sshd -t
sudo systemctl restart sshd
```

## 6) Validate

Try password auth (should fail):

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no azureuser@<public-ip>
```

Check logs:

```bash
journalctl -u ssh -n 200 --no-pager
