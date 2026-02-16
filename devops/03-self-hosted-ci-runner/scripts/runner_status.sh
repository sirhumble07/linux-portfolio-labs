#!/usr/bin/env bash
set -euo pipefail

# This script checks the status of the self-hosted CI runner service and its processes.
cd ~/actions-runner
sudo ./svc.sh status || true
ps aux | grep -i Runner.Listener | grep -v grep || true