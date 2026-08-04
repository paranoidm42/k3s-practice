#!/bin/bash

SERVER_URL="https://192.168.56.110:6443"
IP_AGENT="192.168.56.111"
SECRET_TOKEN="MySecretToken"



sudo apt-get update -y
sudo apt-get install -y curl gettext-base

echo ">>> [WORKER] K3s Worker setup starting..."

curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="agent \
        --server $SERVER_URL \
        --token $SECRET_TOKEN \
        --node-ip $IP_AGENT" \
    sh -s -

echo ">>> [WORKER] Agent service  waiting..."
sleep 10


echo ">>> [WORKER] Setup completed!"
echo "Worker IP: $IP_AGENT"
echo "Server URL: $SERVER_URL"
echo "RAM: $(free -h | awk '/Mem/ {print $3"/"$2}')"


if pgrep k3s >/dev/null; then
    echo "K3s Agent Status: running"
    echo "Worker uccessfully connected to the server.."
else
    echo "K3s Agent Status: stopped"
    echo "HATA: Worker could not connect to the server.."
fi

sudo systemctl status  k3s-agent
