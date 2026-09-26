#!/usr/bin/env bash
# Create the lab's kind cluster (1 control plane, 2 workers) and install
# metrics-server, which the HorizontalPodAutoscalers need. Safe to re-run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
CLUSTER=superlab

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "==> kind cluster ${CLUSTER} already exists"
else
  echo "==> creating kind cluster ${CLUSTER}"
  kind create cluster --config cluster/kind.yaml --wait 180s
fi
kubectl config use-context "kind-${CLUSTER}" >/dev/null

echo "==> metrics-server"
kubectl apply -k cluster/metrics-server
kubectl -n kube-system rollout status deploy/metrics-server --timeout=180s

kubectl get nodes
echo "[ok] cluster ready; deploy with: make deploy ENV=dev"
