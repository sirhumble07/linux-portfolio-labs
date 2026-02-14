# Linux Security Hardening - DevSecOps

## STEP 0 — SAFETY RULES (do this first)

**Before changing SSH:**

- Ensure you can already SSH in with a key
- Keep a second SSH session open
- If you're on Azure: ensure NSG still allows your IP to port 22

**If you lock yourself out, you lose time — pros prevent this.**

---

## STEP 1 — Update OS and install tools

```bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install ufw fail2ban
```

Validate:

```bash
ufw --version
fail2ban-client --version
```

📸 **See Screenshot:** versions output

---

## STEP 2 — SSH hardening (OS level)

### 2.1 Backup config

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

### 2.2 Edit sshd_config

```bash
sudo nano /etc/ssh/sshd_config
```

Set/ensure:

```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

**What these mean (interview gold):**

- `PasswordAuthentication no` → blocks brute-force password attacks
- `PermitRootLogin no` → attackers can't target root directly
- `PubkeyAuthentication yes` → SSH keys only (expected in production)

### 2.3 Validate before restart

```bash
sudo sshd -t
```

Expected: no output (means valid)

### 2.4 Restart SSH

```bash
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
```

📸 **See Screenshots:**

- sshd_config snippet
- sshd -t
- ssh service status

---

## STEP 3 — Prove password auth is disabled (validation)

From a NEW terminal (not your active session):

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <user>@<server-ip>
```

Expected: `Authentication failure`

📸 **See Screenshot:** failed password attempt output

---

## STEP 4 — Configure firewall (UFW)

### 4.1 Allow SSH first (prevents lockout)

```bash
sudo ufw allow OpenSSH
```

### 4.2 If you run web services, allow HTTP/HTTPS (optional)

If this machine runs Nginx proxy:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 4.3 Enable firewall

```bash
sudo ufw enable
sudo ufw status verbose
```

**Expected:**

- Status: active
- Default incoming: deny
- Allowed: SSH (+ HTTP/HTTPS if you enabled them)

📸 **See Screenshot:** ufw status verbose

---

## STEP 5 — Validate exposed ports (Linux proof)

```bash
ss -tulpn
```

**What you want to see:**

- 22 listening
- 80/443 only if you intentionally run them
- no random ports

📸 **Screenshot:** ss -tulpn

---

## STEP 6 — Enable and configure fail2ban (intrusion prevention)

### 6.1 Start fail2ban

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban --no-pager
```

📸 **See Screenshot:** fail2ban service status

### 6.2 Create local jail configuration (best practice)

**Do NOT edit the default file directly.**

```bash
sudo tee /etc/fail2ban/jail.d/sshd.local >/dev/null <<'EOF'
[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = 5
findtime = 10m
bantime = 1h
EOF
```

Restart:

```bash
sudo systemctl restart fail2ban
```

Validate jail:

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

**Expected:**

- sshd jail enabled
- shows current banned count (likely 0)

📸 **See Screenshot:** fail2ban-client status sshd

---

## STEP 7 — Audit evidence (what you commit)

Run and capture outputs:

```bash
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|pubkeyauthentication'
sudo ufw status verbose
sudo fail2ban-client status sshd
```

📸 **Screenshots:**

- ssh effective settings
- ufw rules
- fail2ban sshd jail status

---
