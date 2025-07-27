FROM docker.io/pytorch/pytorch:2.7.1-cuda12.6-cudnn9-runtime

# Install essential utilities
RUN apt-get update && apt-get install -y \
    wget \
    tree \
    nano \
    curl \
    net-tools \
    iputils-ping \
    nginx \
    git
    
# Install Tailscale
# https://docs.salad.com/container-engine/how-to-guides/platform-integrations/tailscale-basic
RUN curl -fsSL https://tailscale.com/install.sh | sh
# Install and configure proxychains4 to use Tailscale's SOCKS5 proxy (Optional)
RUN apt-get install -y proxychains4 
RUN sed -i 's/socks4[[:space:]]\+127\.0\.0\.1[[:space:]]\+9050/socks5  127.0.0.1 1055/' /etc/proxychains4.conf

# Install VS Code Server for remote debugging
# https://docs.salad.com/container-engine/tutorials/development-tools/vscode-remote-development#interactive-mode
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' -o vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz && \
    mv code /usr/local/bin/code && \
    rm vscode_cli.tar.gz
# To connect using VS Code:
# Log in the instance using the terminal, and then run the following commands:
# code tunnel user login --provider github
# nohup code tunnel --accept-server-license-terms --name 001 &> output.log &

RUN pip install --upgrade pip
RUN pip install ray[data,train,tune,serve]==2.47.1
RUN pip install jupyterlab ipywidgets
RUN pip install transformers accelerate datasets 
RUN pip install python-dotenv flask speedtest-cli pythonping

# Enable IPv4/v6 dual-stack support on Nginx for SaladCloud's Container Gateway
# Listen on Port 8000
COPY routing.conf /etc/nginx/sites-available/routing.conf
RUN ln -s /etc/nginx/sites-available/routing.conf /etc/nginx/sites-enabled/routing.conf
# cat /etc/nginx/nginx.conf
# nano /etc/nginx/nginx.conf
# nano /etc/nginx/sites-available/routing.conf
# ./restart_nginx.sh

WORKDIR /app
COPY Dockerfile routing.conf restart_nginx.sh start.sh initial_check.py ray* test* /app/
RUN chmod +x /app/start.sh
RUN chmod +x /app/restart_nginx.sh

CMD ["./start.sh"]

#         Nginx
# ------> 8000 IPv4/v6 --- /ray/     --> 8265 IPv4,    Ray Dashboard
#                     \--- /jupyter/ --> 8889 IPv4/v6, Jupyter Lab

# The pre-built images 
# docker.io/saladtechnologies/ray:001-test
# docker.io/saladtechnologies/ray:002-test


# VS Code Remote - SSH
# root@tailscale-ip
# Python Extension 

# GitHub Repository 
# https://github.com/SaladTechnologies/ray-cluster
# git config --global user.name ""
# git config --global user.email ""

# tailscale status
# tailscale ip
# tailscale ping tailscale-ip
# ALL_PROXY=socks5://localhost:1055/ curl http://tailscale-ip
# http_proxy=http://localhost:1055/ curl http://tailscale-ip
# proxychains4 curl http://tailscale-ip

# python -m http.server 8000