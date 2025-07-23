#!/bin/bash
# run-app-only.sh
# Purpose: Get the Node.js app running (without installing all system dependencies)

# Optional: Set DB_HOST for the database connection.
# Uncomment the line below and update <DB_VM_IP> with the IP address of your DB VM.
# export DB_HOST="mongodb://<DB_VM_IP>:27017/posts"

# Change directory to the app folder.
# Replace /path/to/app with the actual path to your application directory.
pm2 status
cd /repo/app

# Optional: Install npm dependencies if needed.
# Uncomment the line below if you want to seed the database or verify the connection.
npm install

# Start the Node.js app using PM2.
pm2 start app.js --name app

