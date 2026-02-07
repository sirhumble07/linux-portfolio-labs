# linux-sysadmin/02-nginx-or-apache-webserver/README.md

```md
# Linux Web Server: Nginx/Apache Deployment + Firewall Hardening

## What you will build
A production-style Linux web server setup:
- Install **Nginx** (recommended) or Apache
- Configure a site (server block / virtual host)
- Enable firewall rules with **UFW**
- Validate service health and port exposure

## Why this matters in real jobs
Running web services safely is common in sysadmin work:
- hosting internal dashboards
- reverse proxies
- config management endpoints
- static documentation portals

## Skills you will demonstrate
- `systemctl` service lifecycle
- Nginx server blocks
- Firewall controls (UFW)
- Troubleshooting with logs

## Prerequisites
- Ubuntu Server VM
- SSH access
- Server IP reachable from your laptop

## Success criteria
- `http://<server-ip>` returns your custom page
- Only ports you expect are open (22 and 80; optionally 443)

## Next extensions
- Add TLS after you get a domain
- Add reverse proxy routing to backends
