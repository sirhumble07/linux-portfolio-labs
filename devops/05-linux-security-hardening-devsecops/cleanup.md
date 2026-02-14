# Cleanup Guide - Linux Security Hardening

## ⚠️ Important Warning

**Reversing security hardening may expose your system to attacks.**

Only perform this cleanup if:

- This was a lab/test environment
- You're decommissioning the server
- You understand the security implications

**For production systems:** Keep hardening in place and follow your organization's security policies.

---

## Option 1: Keep Security Settings (Recommended)

If this is a real server you're keeping, **do not revert these changes**. The hardening should remain in place.

Skip to [Verification](#verification) to confirm everything is still working correctly.

---

## Option 2: Revert SSH Configuration

**Only do this if you need password authentication back (not recommended).**

### Restore SSH Config

```bash
# Restore backup
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config

# Or manually re-enable password auth
sudo nano /etc/ssh/sshd_config
```

Change these lines back:

```text
PasswordAuthentication yes
PermitRootLogin yes
```

Validate and restart:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

**Warning:** This makes your system vulnerable to brute-force attacks.

---

## Option 3: Disable fail2ban

If you need to disable intrusion prevention:

```bash
# Stop and disable service
sudo systemctl stop fail2ban
sudo systemctl disable fail2ban

# Check status
sudo systemctl status fail2ban
```

**Warning:** Without fail2ban, attackers can repeatedly attempt SSH connections.

---

## Option 4: Disable UFW Firewall

**Only disable if absolutely necessary.**

```bash
# Disable firewall
sudo ufw disable

# Verify status
sudo ufw status
```

**Warning:** This removes network-level protection.

---

## Complete Removal (Test Environments Only)

If this was purely a lab environment you're tearing down:

```bash
# Remove fail2ban
sudo apt remove --purge fail2ban -y
sudo rm -rf /etc/fail2ban

# Remove UFW
sudo apt remove --purge ufw -y

# Restore SSH defaults
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh

# Clean up backup
sudo rm /etc/ssh/sshd_config.bak
```

---

## Verification

After any changes, verify SSH still works:

### Test SSH Access

From a **different terminal**:

```bash
ssh <user>@<server-ip>
```

Expected: You can still log in with your SSH key.

### Verify Services

```bash
# Check SSH
sudo systemctl status ssh

# Check fail2ban (if kept)
sudo systemctl status fail2ban

# Check firewall (if kept)
sudo ufw status
```

---

## Restore Default SSH Port (Optional)

If you changed the SSH port during hardening:

```bash
sudo nano /etc/ssh/sshd_config
```

Change:

```text
Port 22
```

Restart:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

Update firewall:

```bash
sudo ufw allow 22/tcp
sudo ufw delete allow <old-port>/tcp
```

---

## Remove Custom fail2ban Jails

If you created custom jail configurations:

```bash
# Remove custom jail
sudo rm /etc/fail2ban/jail.d/sshd.local

# Restart fail2ban
sudo systemctl restart fail2ban
```

---

## Audit Cleanup

Verify what's been changed:

```bash
# Check SSH config
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|pubkeyauthentication'

# Check firewall
sudo ufw status verbose

# Check fail2ban status
sudo fail2ban-client status

# Check listening ports
ss -tulpn
```

---

## Re-Enable Password Authentication (Not Recommended)

If you absolutely must re-enable passwords:

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

Set:

```text
PasswordAuthentication yes
```

Restart:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

Test from another terminal:

```bash
ssh -o PreferredAuthentications=password <user>@<server-ip>
```

**Security Warning:** This makes your server vulnerable. Consider:

- Using strong passwords (minimum 16 characters)
- Keeping fail2ban enabled
- Monitoring auth logs: `sudo tail -f /var/log/auth.log`

---

## System State After Cleanup

Depending on what you reverted:

### If You Kept Everything (Recommended)

- ✅ SSH keys still required
- ✅ Firewall still active
- ✅ fail2ban still monitoring
- ✅ System is secure

### If You Reverted Everything (Not Recommended)

- ⚠️ Password authentication enabled
- ⚠️ No firewall protection
- ⚠️ No intrusion prevention
- ⚠️ System is vulnerable

---

## Monitor After Changes

If you made any changes, monitor for issues:

```bash
# Watch auth attempts
sudo tail -f /var/log/auth.log

# Check for banned IPs (if fail2ban still active)
sudo fail2ban-client status sshd

# Monitor connections
sudo ss -tn state established
```

---

## Best Practices Going Forward

### Keep These Enabled

- ✅ SSH key authentication
- ✅ fail2ban
- ✅ UFW firewall
- ✅ Disabled root login

### Only Disable If

- You have a documented business reason
- You implement alternative security controls
- You understand the risk

### Never Do This in Production

- ❌ Disable SSH keys for passwords
- ❌ Allow root login
- ❌ Disable firewall without replacement
- ❌ Remove intrusion prevention

---

## Emergency Recovery

If you locked yourself out:

1. **Use Azure Serial Console** (if on Azure)
2. **Use cloud provider recovery console**
3. **Mount disk to another VM** and edit configs
4. **Restore from backup** if available

Prevention:

- Always keep a second SSH session open when testing
- Test changes in a safe environment first
- Document all changes made

---

## Notes

- SSH hardening settings are **intentional security measures**
- Reverting them should only be done with full understanding
- Production systems should maintain these protections
- This lab demonstrated **industry-standard security practices**

---

## Related Documentation

- [steps.md](steps.md) - How hardening was implemented
- [hardening-checklist.md](hardening-checklist.md) - Security validation checklist
- [README.md](README.md) - Project overview

---

**Remember: Security hardening exists for a reason. Only revert these changes if you fully understand the implications.**
