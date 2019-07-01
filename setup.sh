#!/bin/sh

set -e

SKAFFOLD_VERSION=0.30.0
HELM_VERSION=2.14.1
CST_VERSION=1.8.0
KUBECTL_VERSION=1.15.0

curl -fsLo skaffold https://github.com/GoogleCloudPlatform/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 && \
  chmod +x skaffold && \
  mv skaffold /usr/bin

curl -fsLo container-structure-test https://storage.googleapis.com/container-structure-test/v${CST_VERSION}/container-structure-test-linux-amd64 && \
  chmod +x container-structure-test && \
  mv container-structure-test /usr/bin

curl -fsL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -zx && \
  chmod +x linux-amd64/helm && \
  mv linux-amd64/helm /usr/bin && \
  rm -rf linux-amd64
  
curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv kubectl /usr/bin
  
