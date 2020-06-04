#!/usr/bin/env bash

kind export kubeconfig

printf "Waiting for CNI to be ready"
while : ; do
    cniReady=$(kubectl get daemonset -n kube-system kindnet -o jsonpath="{.status.numberReady}" 2>/dev/null)
    if [[ "${cniReady}" == "1" ]]; then
        echo
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for kube-proxy to be ready"
while : ; do
    kubeProxyReady=$(kubectl get daemonset -n kube-system kube-proxy -o jsonpath="{.status.numberReady}" 2>/dev/null)
    if [[ "${kubeProxyReady}" == "1" ]]; then
        echo
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for control plane to be ready"
while : ; do
    status=$(kubectl get pod -n kube-system kube-apiserver-kind-control-plane -o jsonpath="{.status.phase}" 2>/dev/null)
    if [[ "${status}" == "Running" ]]; then
        echo
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for CoreDNS pods to be ready"
while : ; do
    coreDnsReadyPods=$(kubectl get deploy -n kube-system coredns -o jsonpath="{.status.readyReplicas}" 2>/dev/null)
    coreDnsExpectedReadyPods=$(kubectl get deploy -n kube-system coredns -o jsonpath="{.status.replicas}" 2>/dev/null)
    coreDnsReady=$(expr ${coreDnsReadyPods} / ${coreDnsExpectedReadyPods} 2>/dev/null)
    if [[ "${coreDnsReady}" == "1" ]]; then
        echo
        break
    fi
    printf '.'
    sleep 2
done

printf "Waiting for Kubernetes cluster to be ready"
while : ; do
    nodeReadyStatus=$(kubectl get node kind-control-plane -o jsonpath="{.status.conditions[?(@.type==\"Ready\")].status}" 2>/dev/null)
    if [[ "${nodeReadyStatus}" == "True" ]]; then
        echo
        break
    fi
    printf '.'
    sleep 2
done
