#!/bin/bash

IP_SRV="192.168.56.110"
SECRET_TOKEN="MySecretToken"

echo ">>> [SERVER] Starting K3s Server installation..."

sudo apk add envsubst

export IP_SRV
export SECRET_TOKEN
mkdir -p /etc/rancher/k3s
envsubst </confs_data/config.yaml >/etc/rancher/k3s/config.yaml
chown root:root /etc/rancher/k3s/config.yaml
chmod 0644 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io | sh -s -

sleep 10

echo ">>> [SERVER] Waiting for K3s to be ready..."
until sudo k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes &>/dev/null; do
  echo "Waiting for K3s to be ready..."
  sleep 5
done

# Remove master node taint to allow pod scheduling
sudo k3s kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule- 2>/dev/null || true
sudo k3s kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule- 2>/dev/null || true

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

echo ""
echo ">>> [SERVER] Deploying applications..."
sudo k3s kubectl apply -f /confs_data/app-one.yaml
sudo k3s kubectl apply -f /confs_data/app-two.yaml
sudo k3s kubectl apply -f /confs_data/app-three.yaml

echo ""
echo ">>> [SERVER] Waiting for deployments to be ready..."
sleep 10

echo ""
echo "Deployments:"
sudo k3s kubectl get deployments -A

echo ""
echo "Services:"
sudo k3s kubectl get services -A

echo ""
echo "Ingress:"
sudo k3s kubectl get ingress -A

echo ""
echo "Pods:"
sudo k3s kubectl get pods -A -o wide
