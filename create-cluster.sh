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
    --image kindest/node:v1.15.6@sha256:18c4ab6b61c991c249d29df778e651f443ac4bcd4e6bdd37e0c83c0d33eaae78 \
    --wait 5m \
    --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://${registryIp}:5000"]
EOF
