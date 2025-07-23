#!/bin/bash
set -e

# Usage: ./sparta.sh
# This script installs and configures the App Tier (Nginx, Node.js, and PM2) on Ubuntu 22.04.
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

#echo "Running system upgrade in non-interactive mode..."
#DEBIAN_FRONTEND=noninteractive apt-get \
#     -o Dpkg::Options::="--force-confdef" \
#     -o Dpkg::Options::="--force-confold" \
#     upgrade -y

echo "=============================================="
echo "Setting up App Tier (Nginx, Node.js, PM2)..."
echo "=============================================="

echo "Updating system packages..."
apt-get update -qq > /dev/null 2>&1
apt-get upgrade -y -qq > /dev/null 2>&1

echo "Installing nginx..."
DEBIAN_FRONTEND=noninteractive apt install -y nginx > /dev/null 2>&1

echo "Enabling and starting nginx..."
systemctl enable nginx > /dev/null 2>&1
systemctl start nginx > /dev/null 2>&1

echo "Installing Node.js and npm..."
DEBIAN_FRONTEND=noninteractive bash -c "curl -fsSL https://deb.nodesource.com/setup_20.x | bash -" > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt install -y nodejs > /dev/null 2>&1

echo "Installing PM2 globally..."
npm install -g pm2 > /dev/null 2>&1

echo "Cloning Node.js app repository..."
git clone https://github.com/stravos97/node-sparta-test-app.git /repo > /dev/null 2>&1

echo "Configuring Nginx reverse proxy..."
# Replace the 'try_files' directive with our proxy_pass configuration
sed -i 's|try_files.*|proxy_pass http://127.0.0.1:3000;|' /etc/nginx/sites-available/default

echo "Reloading nginx configuration..."
systemctl reload nginx > /dev/null 2>&1

# Connect to the mongodb server
#export DB_HOST=mongodb://<db_private_ip>:27017/posts

echo "Changing directory to the app repository..."
cd /repo/app

echo "Installing Node.js application dependencies..."
npm install > /dev/null 2>&1

echo "Starting the Node.js app with PM2..."
pm2 start app.js > /dev/null 2>&1

echo "=============================================="
echo "Final Configuration and Service Statuses"
echo "=============================================="

echo "Current 'proxy_pass' configuration in Nginx:"
grep "proxy_pass" /etc/nginx/sites-available/default

echo "----------------------------------------------"
echo "Nginx service status:"
systemctl status nginx --no-pager

echo "----------------------------------------------"
echo "PM2 process list:"
pm2 list

