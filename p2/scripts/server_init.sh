#!/bin/bash
set -e

TIMEOUT=300
ELAPSED=0

export IP_SRV="192.168.56.110"
export SECRET_TOKEN="MySecretToken"

echo "[SERVER] Bağımlılıklar yükleniyor..."

sudo apt-get update -y
sudo apt-get install -y curl gettext-base

echo "[SERVER] K3s konfigürasyon dosyası hazırlanıyor..."
sudo mkdir -p /etc/rancher/k3s

envsubst < /confs_data/config.yaml | sudo tee /etc/rancher/k3s/config.yaml > /dev/null

sudo chmod 0644 /etc/rancher/k3s/config.yaml

echo "[SERVER] K3s kuruluyor (config.yaml ayarlarıyla birlikte)..."
curl -sfL https://get.k3s.io | sh -

echo "[SERVER] K3s'in ayağa kalkması bekleniyor..."


until sudo k3s kubectl get nodes || [ $ELAPSED -ge $TIMEOUT ]; do
  sleep 1
  ELAPSED=$((ELAPSED + 1))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
  echo "[ERROR]: K3s readiness timeout after ${TIMEOUT}s"
  exit 1
fi

echo "[SERVER] Uygulamalar deploy ediliyor..."
sudo k3s kubectl apply -f /confs_data/app-one.yaml
sudo k3s kubectl apply -f /confs_data/app-two.yaml
sudo k3s kubectl apply -f /confs_data/app-three.yaml

echo "[SERVER] Kurulum tamamlandı!"
sudo k3s kubectl get nodes --show-labels