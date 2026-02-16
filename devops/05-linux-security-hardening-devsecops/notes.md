# Notes — DevOps Lab 5

## Security layering

- Cloud NSG: outer firewall
- Host firewall (UFW): inner firewall
- SSH hardening: reduces credential attack surface
- fail2ban: mitigates brute-force attempts

## Audit mindset

Always collect proof:

- effective sshd settings
- firewall rules
- fail2ban jail status
