#!/bin/bash
#
# Docker Installation Script for Ubuntu 22.04+
# Part of: devops/01-linux-docker-host lab
#
# Purpose:
#   - Install Docker Engine (docker.io package)
#   - Enable Docker service
#   - Add current user to docker group
#   - Validate installation
#
# Usage:
#   chmod +x docker-install-ubuntu.sh
#   ./docker-install-ubuntu.sh
#
# Requirements:
#   - Ubuntu 22.04 or newer
#   - sudo privileges
#   - Internet connection

set -e  # Exit on error

echo "========================================="
echo "Docker Installation for Ubuntu"
echo "========================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "ERROR: Do not run this script as root"
   echo "Run as a regular user with sudo privileges"
   exit 1
fi

# Check for sudo privileges
if ! sudo -v; then
    echo "ERROR: This script requires sudo privileges"
    exit 1
fi

echo "[1/5] Updating system packages..."
sudo apt update
sudo apt -y upgrade

echo ""
echo "[2/5] Installing Docker Engine..."
sudo apt -y install docker.io

echo ""
echo "[3/5] Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "[4/5] Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

echo ""
echo "[5/5] Validating installation..."
docker --version
sudo systemctl status docker --no-pager | head -n 5

echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "IMPORTANT: You need to log out and log back in"
echo "for group membership to take effect."
echo ""
echo "After logging back in, verify with:"
echo "  docker ps"
echo "  groups"
echo ""
echo "To activate docker group in current shell (temporary):"
echo "  newgrp docker"
echo ""