#!/usr/bin/env bash

set -euo errexit

clusterName="kind"
registryName="kind-registry"
registryRunning="$(docker inspect -f '{{.State.Running}}' "${registryName}" 2>/dev/null || true)"

if [[ "${registryRunning}" != 'true' ]]; then
  docker run -d \
    -p 5000:5000 \
    --restart=always \
    --name=${registryName} \
    -v $HOME/registry-2:/var/lib/registry \
    --env REGISTRY_STORAGE_DELETE_ENABLED=true \
    registry:2
fi

registryIp="$(docker network inspect bridge --format '{{(index .IPAM.Config 0).Gateway}}')"

cat <<EOF | kind create cluster \
    --name "${clusterName}" \
    --image kindest/node:v1.20.7@sha256:cbeaf907fc78ac97ce7b625e4bf0de16e3ea725daf6b04f930bd14c67c671ff9 \
    --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://${registryIp}:5000"]
EOF

docker stop kind-control-plane
cp -n kind-control-plane.service /etc/systemd/system
sudo systemctl enable kind-control-plane
sudo systemctl start kind-control-plane
