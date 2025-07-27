#!/bin/bash

echo -e "\nRestarting nginx ..."

# Find nginx master process PID
NGINX_PID=$(pgrep -x nginx)

# If nginx is running
if [ -n "$NGINX_PID" ]; then
    echo "Stopping nginx (PID: $NGINX_PID) ..."
    nginx -s quit 2>/dev/null || kill $NGINX_PID
    sleep 1
else
    echo "No running nginx found."
fi

# Start nginx in the background safely
echo "Starting nginx ..."
nginx &

# Confirm status
if pgrep -x nginx > /dev/null; then
    echo "nginx restarted successfully."
else
    echo "Failed to start nginx."
fi
