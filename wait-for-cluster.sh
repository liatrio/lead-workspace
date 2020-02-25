#!/usr/bin/env bash

while : ; do
    status=$(kubectl get pod -n kube-system kube-apiserver-kind-control-plane -o jsonpath="{.status.phase}")
    if [[ "${status}" == "Running" ]]; then
        break
    fi
    sleep 1
done
