
# linux-sysadmin/04-logs-troubleshooting-incident-sim/README.md

```md
# Log Management + Incident Simulation: Diagnose and Fix a Broken Service

## What you will build
A controlled incident drill:
- intentionally break a service (Nginx)
- diagnose using `systemctl` + `journalctl` + service logs
- fix and validate recovery
- write an incident report

## Why it matters
Interviewers want proof you can troubleshoot under pressure.

## Skills
- systemd troubleshooting
- journal/log analysis
- root cause documentation
- safe recovery methods

## Success criteria
- You can reproduce the failure
- You fix it
- You document root cause + prevention
