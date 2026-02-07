# linux-sysadmin/03-backups-cron-rsync-rotation/README.md

```md
# Automated Backups: cron + rsync + Logging + Restore Test

## What you will build
A reliable backup workflow that:
- backs up important directories (example: `/etc`, `/var/www`)
- writes timestamped backups to `/backup/<timestamp>/`
- logs every run
- performs a restore test (proof)

## Why this matters in real jobs
Backups are meaningless unless you can restore.
This lab proves you can:
- automate backups
- verify outputs
- document restore procedures

## Skills
- `rsync` options and safe usage
- `cron` scheduling and PATH safety
- validation (checksums)
- operational documentation

## Success criteria
- Backup runs successfully
- Restore test succeeds and is documented
