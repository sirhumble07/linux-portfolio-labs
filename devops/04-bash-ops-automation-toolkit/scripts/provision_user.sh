#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER="$1"

if id "$USER" &>/dev/null; then
  echo "User $USER already exists"
  exit 0
fi

sudo useradd -m -s /bin/bash "$USER"
sudo passwd "$USER"
sudo usermod -aG sudo "$USER"

echo "User $USER created and added to sudo group"
