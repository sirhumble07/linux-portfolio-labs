# Multi-User Linux Server: RBAC, Permissions & Sudo Hardening

## What you will build

A multi-user Linux server layout that enforces:

- Role-based access using **users + groups**
- Secure privilege escalation using **sudoers**
- Shared folder collaboration using **setgid + ACLs**
- A clear permissions model that you can explain in interviews

## Why this matters in real jobs

Nearly every Linux sysadmin role requires you to:

- Create and manage users and groups
- Prevent privilege creep
- Ensure only the right people can access the right data
- Fix permission issues quickly under pressure

## Skills Demonstrated

- User/group lifecycle: `useradd`, `usermod`, `groupadd`, `id`
- Permissions: `chmod`, `chown`, setgid bit
- ACLs: `setfacl`, `getfacl`
- Safe sudo policies: `visudo`, `/etc/sudoers.d/`
- Validation and auditing

## Prerequisites

- Ubuntu Server 22.04+ VM (local or cloud)
- One admin account with sudo
- SSH access (recommended)
- Snapshot/revert point (recommended)

## Deliverables (commit to GitHub)

- `steps.md` completed
- A permissions matrix (in this README)
- Sanitized sudo policy example (no usernames tied to real orgs)
- Screenshots of validation steps

## Permissions matrix (target state)

| Role     | Can write to /srv/projects | Can read logs | Has sudo |
|----------|----------------------------|---------------|----------|
| dev1     | Yes                        | No            | No       |
| audit1   | No (read-only ok)          | Yes           | No       |
| admin    | Yes                        | Yes           | Yes      |

## Success criteria

- `dev1` can create files in `/srv/projects` but cannot change system files.
- `audit1` can read logs but cannot sudo.
- Sudo policy passes validation: `sudo visudo -c`

## Next extensions

- Add fail2ban and SSH hardening
- Add centralized auth (LDAP/FreeIPA) later

## Goal

Build a multi-user Linux access model that mirrors real organizations:

- Developers can collaborate in shared directories
- Auditors can read but not write
- Sudo access is controlled via `/etc/sudoers.d` (safe practice)

## Validation Evidence Checklist

- [ ] `getent group devs` and `getent group auditors`
- [ ] `id dev1` includes `devs`
- [ ] `id audit1` includes `auditors`
- [ ] `ls -ld /srv/projects/app1` shows `drwxrws---`
- [ ] `getfacl /srv/projects/app1` shows auditors `rx` + default ACL
- [ ] `dev1` can create file in `/srv/projects/app1`
- [ ] `audit1` can read but cannot create file
- [ ] `sudo visudo -c` passes

## Screenshots Folder

Store proof screenshots in:
`assets/screenshots/`
