#!/bin/bash
set -e

export IP_SRV="192.168.56.110"
export SECRET_TOKEN="MySecretToken"

echo ">>> [SERVER] Alpine bağımlılıkları ve cgroup ayarları yapılıyor..."

apk add --no-cache gettext curl libc6-compat cni-plugins

rc-update add cgroups default
rc-service cgroups start || true

if ! grep -q "cgroup_enable=memory" /etc/update-extlinux.conf; then
    sed -i 's/default_kernel_opts="/default_kernel_opts="cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory /' /etc/update-extlinux.conf
    update-extlinux
    echo ">>> [WARNING] Kernel ayarları güncellendi. 'vagrant reload' yapmanız gerekebilir!"
fi

echo ">>> [SERVER] K3s yapılandırması hazırlanıyor..."
mkdir -p /etc/rancher/k3s
envsubst < /confs_data/config.yaml > /etc/rancher/k3s/config.yaml
chmod 0644 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io | sh -

echo ">>> [SERVER] K3s'in ayağa kalkması bekleniyor..."


retry=0
while ! k3s kubectl get nodes >/dev/null 2>&1; do
  retry=$((retry+1))
  if [ $retry -gt 20 ]; then echo "Hata: K3s zaman aşımına uğradı"; exit 1; fi
  sleep 5
done

echo ">>> [SERVER] Deploying applications..."

k3s kubectl apply -f /confs_data/app-one.yaml
k3s kubectl apply -f /confs_data/app-two.yaml
k3s kubectl apply -f /confs_data/app-three.yaml

echo ">>> [SERVER] Kurulum tamamlandı!"
k3s kubectl get nodes
