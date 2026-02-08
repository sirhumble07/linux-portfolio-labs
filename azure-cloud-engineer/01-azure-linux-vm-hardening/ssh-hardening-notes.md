# SSH Hardening Notes

## Critical SSH Security Settings

### 1. Disable Password Authentication

```text
PasswordAuthentication no
```

**Why**: Password-based authentication is vulnerable to brute force attacks. Key-based authentication is significantly more secure as private keys are much longer and more complex than typical passwords.

**Impact**: Users must have the private key to authenticate. Password attempts will be rejected.

### 2. Disable Root Login

```text
PermitRootLogin no
```

**Why**: Direct root access is a security risk. If compromised, attackers have full system control. Best practice is to use a regular user account with `sudo` privileges.

**Impact**: Cannot SSH directly as root. Must SSH as a regular user and use `sudo` for privileged operations.

## Additional Hardening Recommendations

### Consider These Settings (Not Required for Lab)

```text
# Limit SSH protocol to version 2 only
Protocol 2

# Set idle timeout (5 minutes)
ClientAliveInterval 300
ClientAliveCountMax 0

# Disable X11 forwarding if not needed
X11Forwarding no

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3

# Specify allowed users (optional)
AllowUsers azureuser

# Use strong ciphers only
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
```

## Validation Commands

### Before Applying Changes

```bash
# Always backup the original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Test configuration syntax before restarting
sudo sshd -t
```

### After Applying Changes

```bash
# Restart SSH service
sudo systemctl restart sshd

# Check service status
sudo systemctl status sshd

# View recent SSH logs
sudo journalctl -u ssh -n 50 --no-pager

# View authentication logs
sudo tail -f /var/log/auth.log
```

## Testing Security

### Test 1: Password Authentication (Should Fail)

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no azureuser@<public-ip>
```

**Expected Result**: `Permission denied (publickey).`

### Test 2: Root Login (Should Fail)

```bash
ssh -i <key> root@<public-ip>
```

**Expected Result**: `Permission denied (publickey).` or connection closes

### Test 3: Key-Based Auth (Should Succeed)

```bash
ssh -i <path-to-private-key> azureuser@<public-ip>
```

**Expected Result**: Successful login

## Important Warnings

⚠️ **Before restarting SSH service**:

- Always keep an active SSH session open
- Test configuration with `sudo sshd -t`
- Have console access available (Azure Portal Serial Console)

⚠️ **Configuration mistakes can lock you out**:

- Always backup the config file
- Validate syntax before restarting
- Use Azure Portal for emergency access if needed

## Log Analysis

### Key Log Messages

**Successful key-based authentication**:

```text
Accepted publickey for azureuser from <IP> port <PORT> ssh2: RSA SHA256:<fingerprint>
```

**Failed password attempt**:

```text
Connection closed by <IP> port <PORT> [preauth]
Failed password for azureuser from <IP> port <PORT> ssh2
```

**Root login rejection**:

```text
User root not allowed because not listed in AllowUsers
```

## NSG + SSH Hardening = Defense in Depth

- **NSG** (Network Layer): Blocks traffic before it reaches the VM
- **SSH Config** (Application Layer): Enforces authentication rules even if network allows connection

Both layers are essential for comprehensive security.
