FROM pytorch/pytorch:2.7.1-cuda12.6-cudnn9-runtime

RUN apt-get update && apt-get install -y \
    wget \
    tree \
    nano \
    curl \
    nginx 
    
RUN pip install ray[data,train,tune,serve]==2.47.1

RUN pip install jupyterlab ipywidgets

# Optional: Install VS Code Server for remote debugging
# https://docs.salad.com/container-engine/tutorials/development-tools/vscode-remote-development#interactive-mode
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' -o vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz && \
    mv code /usr/local/bin/code && \
    rm vscode_cli.tar.gz
# To connect using VS Code:
# Log in the instance using the terminal, and then run the following commands:
# code tunnel user login --provider github
# nohup code tunnel --accept-server-license-terms --name 001 &> output.log &


RUN pip install transformers accelerate datasets python-dotenv

# Enable IPv4/v6 dual-stack support on Nginx for SaladCloud's Container Gateway
# Listen on Port 8000
COPY routing.conf /etc/nginx/sites-available/routing.conf
RUN ln -s /etc/nginx/sites-available/routing.conf /etc/nginx/sites-enabled/routing.conf
# cat /etc/nginx/nginx.conf
# nano /etc/nginx/nginx.conf
# nano /etc/nginx/sites-available/routing.conf
# ./restart_nginx.sh

WORKDIR /app
COPY Dockerfile routing.conf restart_nginx.sh start.sh ray* test* /app/
RUN chmod +x /app/start.sh
RUN chmod +x /app/restart_nginx.sh

CMD ["./start.sh"]

#          Nginx
# ------> 8000 IPv4/v6 --- /ray/     --> 8265 IPv4,    Ray Dashboard
#                     \--- /jupyter/ --> 8889 IPv4/v6, Jupyter Lab

# docker.io/saladtechnologies/ray:001-test
