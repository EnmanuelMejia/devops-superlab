#!/usr/bin/env bash
# Optional, heavier: Prometheus, Alertmanager and Grafana
# (kube-prometheus-stack), scraping podinfo in every lab namespace.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
KPS_VERSION=91.5.3

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update >/dev/null
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version "$KPS_VERSION" \
  --namespace monitoring --create-namespace \
  --values observability/kube-prometheus-stack.values.yaml \
  --wait --timeout 10m
kubectl apply -f observability/podinfo-podmonitor.yaml

echo "[ok] kube-prometheus-stack ${KPS_VERSION} installed"
echo "Grafana:    kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80"
echo "            admin password: kubectl -n monitoring get secret monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
echo "Prometheus: kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090"
