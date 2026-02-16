#!/usr/bin/env bash
set -euo pipefail
# This script performs a security audit of the Linux system by checking SSH settings, firewall status, fail2ban status, and listening ports. It is intended to be run with sudo privileges to access all necessary information.
echo "=== SSH effective settings ==="
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|pubkeyauthentication'
echo
echo "=== UFW status ==="
sudo ufw status verbose || true
echo
echo "=== fail2ban status ==="
sudo fail2ban-client status sshd || true
echo
echo "=== Listening ports ==="
ss -tulpn || true
