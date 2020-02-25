#!/usr/bin/env bash

kubectl rollout status -n kube-system deploy/coredns
kubectl rollout status -n kube-system daemonset/kindnet
kubectl rollout status -n kube-system daemonset/kube-proxy
