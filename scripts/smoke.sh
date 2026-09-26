#!/usr/bin/env bash
# Check a deployed environment end to end: rollout, health and readiness
# endpoints, the environment's own message, and live HPA metrics.
#   ./scripts/smoke.sh [dev|stage|prod]
set -euo pipefail
ENV="${1:-dev}"
NS="superlab-${ENV}"
PORT="${PORT:-19898}"

kubectl -n "$NS" rollout status deploy/podinfo --timeout=180s

kubectl -n "$NS" port-forward svc/podinfo "${PORT}:9898" >/dev/null 2>&1 &
pf=$!
trap 'kill "$pf" 2>/dev/null || true' EXIT
for _ in $(seq 1 30); do
  curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1 && break
  sleep 1
done

echo "healthz: $(curl -fsS "http://127.0.0.1:${PORT}/healthz")"
echo "readyz:  $(curl -fsS "http://127.0.0.1:${PORT}/readyz")"
info="$(curl -fsS -H 'Accept: application/json' "http://127.0.0.1:${PORT}/")"
echo "info:    ${info}" | tr -d '\n'; echo
grep -q "DevOps SuperLab · ${ENV}" <<<"$info" || { echo "[fail] ${NS} is not serving its ${ENV} message" >&2; exit 1; }

echo "==> waiting for the HPA to read CPU metrics"
for _ in $(seq 1 40); do
  cpu="$(kubectl -n "$NS" get hpa podinfo -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null || true)"
  if [ -n "$cpu" ]; then echo "hpa: ${cpu}% of requested CPU"; break; fi
  sleep 5
done
[ -n "${cpu:-}" ] || { echo "[fail] HPA has no CPU metrics; is metrics-server running?" >&2; exit 1; }

echo "[ok] ${NS} healthy"
