#!/usr/bin/env bash
# Install Gatekeeper, the library constraint templates, then the lab's
# constraints (resource requests and limits in superlab-* namespaces).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> Gatekeeper"
kubectl apply -k policies/gatekeeper/install
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-controller-manager --timeout=300s
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-audit --timeout=300s

echo "==> constraint templates"
kubectl apply -k policies/gatekeeper/templates
for crd in k8scontainerlimits k8scontainerrequests; do
  for _ in $(seq 1 60); do
    kubectl get crd "${crd}.constraints.gatekeeper.sh" >/dev/null 2>&1 && break
    sleep 2
  done
  kubectl wait --for=condition=established "crd/${crd}.constraints.gatekeeper.sh" --timeout=60s
done

echo "==> constraints"
kubectl apply -f policies/gatekeeper/constraints
echo "[ok] Gatekeeper enforces requests and limits in superlab-* namespaces"
