#!/usr/bin/env bash
# Confirm Prometheus is scraping podinfo: at least one target of the
# monitoring/podinfo PodMonitor must report up == 1.
set -euo pipefail
PORT="${PORT:-19090}"

kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus "${PORT}:9090" >/dev/null 2>&1 &
pf=$!
trap 'kill "$pf" 2>/dev/null || true' EXIT

query='up{job="monitoring/podinfo"}'
for _ in $(seq 1 36); do
  body="$(curl -fsS --get "http://127.0.0.1:${PORT}/api/v1/query" --data-urlencode "query=${query}" 2>/dev/null || true)"
  if grep -q '"value":\[[0-9.]*,"1"\]' <<<"$body"; then
    echo "$body"
    echo "[ok] Prometheus is scraping podinfo"
    exit 0
  fi
  sleep 5
done
echo "[fail] no podinfo target reported up; last response: ${body:-none}" >&2
exit 1
