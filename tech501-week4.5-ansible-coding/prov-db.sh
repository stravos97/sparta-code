#!/bin/bash
set -e

# Usage: ./sparta.sh
# This script installs and configures MongoDB on Ubuntu 22.04.
# It also configures needrestart to automatically restart services without prompts.

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (or with sudo)."
  exit 1
fi

echo "----------------------------------------------"
echo "Configuring needrestart for non-interactive mode..."
sudo sed -i 's/^#\?NEEDRESTART_MODE=.*/NEEDRESTART_MODE="a"/' /etc/needrestart/needrestart.conf
export NEEDRESTART_SILENT=1
export NEEDRESTART_MODE=a

echo "Running system upgrade in non-interactive mode..."
DEBIAN_FRONTEND=noninteractive apt-get \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade -y > /dev/null 2>&1

echo "=============================================="
echo "Setting up Database Tier (MongoDB)..."
echo "=============================================="

echo "Updating package lists and upgrading system packages..."
apt-get update -qq > /dev/null 2>&1
apt-get upgrade -y -qq > /dev/null 2>&1

echo "Installing gnupg and curl (required for MongoDB repo)..."
apt-get install -y gnupg curl > /dev/null 2>&1

echo "Importing MongoDB public key and adding repository..."
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null 2>&1

echo "Updating package lists after adding MongoDB repository..."
apt-get update -qq > /dev/null 2>&1

echo "Installing MongoDB packages..."
apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 \
                   mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6 > /dev/null 2>&1

echo "Configuring MongoDB to bind to all IP addresses..."
if grep -q "bindIp:" /etc/mongod.conf; then
  sed -i.bak 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
fi

echo "Starting and enabling MongoDB service (mongod)..."
systemctl start mongod > /dev/null 2>&1
systemctl enable mongod > /dev/null 2>&1

echo "Fetching MongoDB service status..."
systemctl status mongod --no-pager

echo "----------------------------------------------"
echo "Verifying MongoDB installation..."
if command -v mongod >/dev/null 2>&1; then
  echo "MongoDB installed successfully!"
  echo "MongoDB version info:"
  mongod --version | head -n 1
else
  echo "Error: mongod command not found. Installation may have failed."
fi

echo "----------------------------------------------"
BIND_IP=$(grep -E '^\s*bindIp:\s*' /etc/mongod.conf | awk '{print $2}')
echo "Current MongoDB bindIp: $BIND_IP"
echo "----------------------------------------------"
echo "MongoDB installation and configuration complete."

