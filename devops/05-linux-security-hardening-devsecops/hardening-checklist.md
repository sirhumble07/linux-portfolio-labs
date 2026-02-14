# Linux Hardening Checklist (DevSecOps Baseline)

## SSH

- [ ] PasswordAuthentication disabled
- [ ] Root login disabled
- [ ] SSH key auth confirmed working
- [ ] sshd config validated using `sshd -t`

## Firewall

- [ ] UFW enabled
- [ ] Default inbound deny
- [ ] Only required ports allowed (22, and optionally 80/443)
- [ ] Ports verified using `ss -tulpn`

## Intrusion Prevention

- [ ] fail2ban installed and running
- [ ] sshd jail enabled
- [ ] Ban thresholds set (maxretry/findtime/bantime)

## Evidence

- [ ] Screenshots of:
  - SSH effective config
  - UFW status
  - fail2ban status sshd
