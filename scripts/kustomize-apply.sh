#!/usr/bin/env bash
# Apply only to this repository's disposable kind cluster.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
case "${1:-}" in
  dev|stage|prod) environment="$1" ;;
  *) echo 'Usage: kustomize-apply.sh dev|stage|prod (all are local lab namespaces)' >&2; exit 2 ;;
esac
command -v kind >/dev/null
command -v kubectl >/dev/null
if ! kind get clusters | grep -Fxq superlab; then
  echo 'The superlab kind cluster is missing. Run make kind-up first.' >&2
  exit 1
fi
kubectl --context kind-superlab cluster-info >/dev/null
kubectl --context kind-superlab apply -k "$ROOT/kustomize/overlays/$environment"
kubectl --context kind-superlab -n "superlab-$environment" rollout status deployment/health-demo --timeout=120s
