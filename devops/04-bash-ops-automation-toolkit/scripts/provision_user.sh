#!/usr/bin/env bash
set -euo pipefail

# This script provisions a new user on the system with sudo privileges. It takes the username as an argument.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# In a real-world scenario, you might want to add more checks here (e.g., validate the username format, check if the user already exists, etc.) and handle errors more gracefully.
USER="$1"
# Check if the user already exists
if id "$USER" &>/dev/null; then
  echo "User $USER already exists"
  exit 0
fi
# Create the user, set a password, and add to sudo group
sudo useradd -m -s /bin/bash "$USER"
sudo passwd "$USER"
sudo usermod -aG sudo "$USER"
# In a production script, you would want to handle the password more securely (e.g., by generating a random password and outputting it to the user, or by using a secure password management solution).
echo "User $USER created and added to sudo group"
