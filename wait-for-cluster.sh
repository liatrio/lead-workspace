#!/usr/bin/env bash

printf "Waiting for Kind node to be ready"
while : ; do
    nodeReadyStatus=$(kubectl get node kind-control-plane -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    if [[ "${nodeReadyStatus}" == "True" ]]; then
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for CoreDNS pods to be ready"
while : ; do
    coreDnsReadyPods=$(kubectl get deploy -n kube-system coredns -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    coreDnsExpectedReadyPods=$(kubectl get deploy -n kube-system coredns -o jsonpath="{.status.replicas}" 2>/dev/null)
    coreDnsReady=$(expr ${coreDnsReadyPods} / ${coreDnsExpectedReadyPods})
    if [[ "${coreDnsReady}" == "1" ]]; then
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for control plane to be ready"
while : ; do
    status=$(kubectl get pod -n kube-system kube-apiserver-kind-control-plane -o jsonpath="{.status.phase}" 2>/dev/null)
    if [[ "${status}" == "Running" ]]; then
        break
    fi
    printf '.'
    sleep 2
done
