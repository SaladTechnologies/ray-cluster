#!/bin/bash

# RUn nginx in the background
echo -e "\nRunning nginx on port 8000 ..."
nginx &

# Run the OpenMM Setup
echo -e "\nRunning Ray on port 8265 ..."
ray start --head --port=6379 --dashboard-host=0.0.0.0 --dashboard-port=8265 --node-ip-address=localhost &
 
# Run the Jupyter Lab server
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

# Keep the container alive
echo -e "\nSleep infinity ..."
sleep infinity