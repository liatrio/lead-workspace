#!/usr/bin/env bash

set -euo errexit

clusterName="kind"
registryName="kind-registry"
registryPort="32000"
registryRunning="$(docker inspect -f '{{.State.Running}}' "${registryName}" 2>/dev/null || true)"

if [[ "${registryRunning}" != 'true' ]]; then
  docker run \
    -d --restart=always -p "${registryPort}:5000" --name "${registryName}" \
    registry:2
fi

registryIp="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${registryName}")"

cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${registryPort}"]
    endpoint = ["http://${registryIp}:${registryPort}"]
EOF
