#!/usr/bin/env bash

# required install before this script
# - apt update
# - apt upgrade
# - apt install nginx
# - apt install supervisor
# - apt install redis-server
# - apt install python3-pip

IDENTITY_FILE="$HOME/.ssh/aws-ec2-doh.pem"
USER="ubuntu"
HOST="ec2-54-180-104-68.ap-northeast-2.compute.amazonaws.com"
PROJECT_DIR="$HOME/Yolo/Django-Channels"

# SERVER PATH
SERVER_DIR="/home/ubuntu/Django-Channels"
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_SITES_ENABLE="/etc/nginx/sites-enabled"
NGINX_SITES_AVAIABLE="/etc/nginx/sites-available/nginx_app.conf"
SUPERVISOR_CONF="/etc/supervisor/conf.d"

USER_HOST=${USER}@${HOST}
SSH_CONNECT="ssh -i ${IDENTITY_FILE} ${USER_HOST}"
SCP_COM="scp -q -i ${IDENTITY_FILE} -r"

echo " - chown"
${SSH_CONNECT} sudo chown \
ubuntu /etc/nginx /etc/nginx/sites-* /etc/supervisor/conf.d

echo " - remove"
${SSH_CONNECT} sudo rm -rf \
${SERVER_DIR} ${NGINX_CONF} ${NGINX_SITES_ENABLE}/* ${NGINX_SITES_AVAIABLE} ${SUPERVISOR_CONF}/*

echo " - set supervisor, nginx"
# set nginx
${SCP_COM} ${PROJECT_DIR}/.config/nginx.conf ${USER_HOST}:${NGINX_CONF}
${SCP_COM} ${PROJECT_DIR}/.config/nginx_app.conf ${USER_HOST}:${NGINX_SITES_AVAIABLE}
${SSH_CONNECT} sudo ln -s ${NGINX_SITES_AVAIABLE} ${NGINX_SITES_ENABLE}/
# set supervisor
${SCP_COM} ${PROJECT_DIR}/.config/supervisor.conf ${USER_HOST}:${SUPERVISOR_CONF}/

echo " - copy project"
${SCP_COM} ${PROJECT_DIR} ${USER_HOST}:${SERVER_DIR}

echo " - install requirements.txt"
${SSH_CONNECT} sudo pip3 install -r /home/ubuntu/Django-Channels/requirements.txt

echo " - kill & run(background) supervisord"
${SSH_CONNECT} sudo pkill -ef supervisord
${SSH_CONNECT} sudo nohup supervisord -n &>/dev/null &

echo " - finish"
