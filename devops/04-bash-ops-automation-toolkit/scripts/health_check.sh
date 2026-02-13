#!/usr/bin/env bash
set -euo pipefail

echo "=== SYSTEM HEALTH CHECK ==="
echo "Hostname: $(hostname)"
echo "Uptime:"
uptime
echo

echo "CPU & Load:"
nproc
uptime | awk -F'load average:' '{ print $2 }'
echo

echo "Memory:"
free -h
echo

echo "Disk Usage:"
df -h | grep -E '^Filesystem|^/dev/'
echo

echo "Top Processes:"
ps aux --sort=-%mem | head -n 6
