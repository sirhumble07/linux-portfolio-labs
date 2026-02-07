# Steps — Incident Simulation: Diagnose and Fix a Broken Service

## 1) Prepare

```bash
sudo apt update
sudo apt -y install nginx
systemctl status nginx --no-pager
