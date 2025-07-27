#!/bin/bash

#################### Tailscale Setup

if [ -n "$TAILSCALE_AUTH_KEY" ]; then

    # Start the Tailscale daemon with userspace networking mode in the backgound and continue running other commands
    echo -e "\nJoining the Tailscale network..."
    tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
    sleep 5

    # Disable DNS resolution through Tailscale (customize as needed)
    tailscale set --accept-dns=false

    # Bring up Tailscale using the provided auth key and machine ID or 'LOCAL' as fallback
    tailscale up --auth-key=$TAILSCALE_AUTH_KEY --hostname ${SALAD_MACHINE_ID:-LOCAL}
    sleep 5

    # Enable Tailscale SSH on this device
    tailscale set --ssh

    # Retrieve and export the local Tailscale IP, making it accessible for local applications
    echo -e "\nRetrieve the Tailscale IP..."
    export TAILSCALE_IP=$(tailscale ip | head -n 1)
    echo -e "\nTailscale IP for this device: $TAILSCALE_IP"

    # Capture and store all environment variables, includeing system and user environment variables
    # Optionally, you can filter specific variables to be saved 
    printenv > /etc/environment

else
    echo -e "\nTAILSCALE_AUTH_KEY not set. Skipping Tailscale setup."
fi

#################### Nigix

# Run nginx in the background
echo -e "\nRunning nginx on port 8000 ..."
nginx &

#################### Ray

echo -e "\nRunning Ray on port 8265 ..."
ray start --head --port=6379 --dashboard-host=0.0.0.0 --dashboard-port=8265 --node-ip-address=localhost &
 
#################### JupyterLab

echo -e "\nRunning Jupyter Lab on port 8889 ..."
jupyter lab \
  --no-browser \
  --port=8889 \
  --ip=* \
  --allow-root \
  --ServerApp.base_url=/jupyter/ \
  --ServerApp.allow_origin='*' \
  --ServerApp.allow_remote_access=True \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  &

#################### Sleep 

# Keep the container alive
echo -e "\nSleep infinity ..."
sleep infinity