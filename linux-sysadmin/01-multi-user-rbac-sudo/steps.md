# Steps — Multi-User Linux Server: RBAC, Permissions & Sudo Hardening

## 0) Lab assumptions

- You are logged in as a sudo-capable admin user.
- You can revert the VM if you lock yourself out.

## 1) Prepare environment

```bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install acl
