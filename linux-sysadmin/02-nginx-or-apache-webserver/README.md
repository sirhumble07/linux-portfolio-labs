# Lab 02: NGINX or Apache Web Server Setup

## Overview

This lab covers installation, configuration, and management of web servers (NGINX or Apache) on Linux, including virtual hosts, SSL/TLS certificates, and basic security hardening.

## Objectives

- Install and configure NGINX or Apache web server
- Set up multiple virtual hosts
- Configure SSL/TLS with Let's Encrypt
- Implement basic security measures
- Configure logging and monitoring
- Performance tuning basics

## Skills Demonstrated

- Web server installation and configuration
- Virtual host management
- SSL/TLS certificate management
- Web server security
- Log analysis
- HTTP/HTTPS configuration

## Tools & Technologies

- NGINX or Apache HTTP Server
- Let's Encrypt / Certbot
- OpenSSL
- systemctl
- Linux firewall (ufw/firewalld)

## Prerequisites

- Linux system with internet access
- Domain name (optional, can use localhost)
- Root or sudo access
- Port 80 and 443 available

## Time to Complete

Approximately 1-2 hours

## Lab Structure

- `steps.md` - Detailed step-by-step instructions
- `cleanup.md` - Commands to remove lab resources
- `scripts/` - Configuration and automation scripts
- `assets/screenshots/` - Visual documentation

## Expected Outcomes

- Functional web server with multiple sites
- HTTPS configured with valid certificates
- Security headers and hardening applied
- Monitoring and logging configured
- Performance optimization implemented

## References

- [NGINX Documentation](https://nginx.org/en/docs/)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
