#!/bin/bash

IP_SRV="192.168.56.110"
SECRET_TOKEN="MySecretToken"

echo ">>> [SERVER] Starting K3s Server installation..."

mkdir -p /etc/rancher/k3s
envsubst < /confs_data/config.yaml > /etc/rancher/k3s/config.yaml
chown root:root /etc/rancher/k3s/config.yaml
chmod 0644 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io | sh -s -

sleep 10

echo ">>> [SERVER] Waiting for K3s to be ready..."
until sudo k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes &> /dev/null; do
    echo "Waiting for K3s to be ready..."
    sleep 5
done


echo ">>> [SERVER] Installation completed!"
echo "Server IP: $IP_SRV"
echo "Token: $SECRET_TOKEN"
echo "RAM: $(free -h | awk '/Mem/ {print $3"/"$2}')"

if pgrep k3s >/dev/null; then
    echo "K3s Status: running"
else
    echo "K3s Status: stopped"
fi

echo ""
echo "Cluster Nodes:"
sudo k3s kubectl get nodes -o wide
