#!/bin/bash

IP_SRV="192.168.56.110"
SECRET_TOKEN="MySecretToken"

echo ">>> [SERVER] K3s Server kurulumu başlıyor..."


curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="server \
        --token $SECRET_TOKEN \
        --node-ip $IP_SRV \
        --bind-address $IP_SRV \
        --write-kubeconfig-mode=644" \
    sh -s -


echo ">>> [SERVER] K3s başlatılıyor..."
sleep 10

echo ">>> [SERVER] K3s'in hazır olması bekleniyor..."
until sudo k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes &> /dev/null; do
    echo "Waiting for K3s to be ready..."
    sleep 5
done

cp /etc/rancher/k3s/k3s.yaml /confs_data/



#----MONITOR------
echo ">>> [SERVER] Kurulum tamamlandı!"
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
