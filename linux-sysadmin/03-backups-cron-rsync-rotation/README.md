# Lab 03: Backups, Cron, Rsync & Log Rotation

## Overview

This lab demonstrates automated backup strategies using cron scheduling, rsync for efficient data transfer, and log rotation to manage system storage. Learn production-ready backup and maintenance automation.

## Objectives

- Create automated backup scripts
- Schedule recurring tasks with cron
- Use rsync for incremental backups
- Implement backup rotation and retention policies
- Configure system log rotation
- Test backup and restore procedures

## Skills Demonstrated

- Cron job scheduling and management
- Bash scripting for automation
- Rsync usage and optimization
- Backup strategy implementation
- Log management and rotation
- System maintenance automation

## Tools & Technologies

- cron/crontab
- rsync
- logrotate
- tar and compression utilities
- Bash scripting
- Linux filesystem management

## Prerequisites

- Linux system with sufficient storage
- Root or sudo access
- Basic understanding of filesystems
- Familiarity with bash scripting

## Time to Complete

Approximately 1.5-2 hours

## Lab Structure

- `steps.md` - Detailed step-by-step instructions
- `cleanup.md` - Commands to remove lab resources
- `scripts/backup.sh` - Main backup script
- `assets/screenshots/` - Visual documentation

## Expected Outcomes

- Functional automated backup system
- Scheduled cron jobs running reliably
- Incremental backup capability with rsync
- Log rotation configured properly
- Tested backup and restore procedures
- Documentation of backup strategy

## References

- [Cron Documentation](https://man7.org/linux/man-pages/man5/crontab.5.html)
- [Rsync Manual](https://linux.die.net/man/1/rsync)
- [Logrotate Guide](https://linux.die.net/man/8/logrotate)
- [Backup Best Practices](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)
