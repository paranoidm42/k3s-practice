#!/bin/bash

SERVER_URL="https://192.168.56.110:6443"
IP_AGENT="192.168.56.111"
SECRET_TOKEN="MySecretToken"

echo ">>> [WORKER] K3s Worker kurulumu başlıyor..."

curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="agent \
        --server $SERVER_URL \
        --token $SECRET_TOKEN \
        --node-ip $IP_AGENT" \
    sh -s -

echo ">>> [WORKER] Agent servisi bekleniyor..."
sleep 10


echo ">>> [WORKER] Kurulum tamamlandı!"
echo "Worker IP: $IP_AGENT"
echo "Server URL: $SERVER_URL"
echo "RAM: $(free -h | awk '/Mem/ {print $3"/"$2}')"


if pgrep k3s >/dev/null; then
    echo "K3s Agent Status: running"
    echo "Worker başarıyla server'a bağlandı"
else
    echo "K3s Agent Status: stopped"
    echo "HATA: Worker server'a bağlanamadı"
fi

# Alpine için OpenRC servis kontrolü
sudo rc-service k3s-agent status
