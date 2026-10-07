#!/usr/bin/env bash
# A disposable local cluster; optional addon designs live in docs/.
set -euo pipefail
command -v docker >/dev/null
command -v kind >/dev/null
command -v kubectl >/dev/null
docker info >/dev/null
if kind get clusters | grep -Fxq superlab; then
  echo '[info] using the existing superlab kind cluster'
else
  kind create cluster --name superlab --wait 120s
fi
# Always name the lab context. Failed creation must never fall through to the
# user's unrelated current cluster.
kubectl --context kind-superlab cluster-info
kubectl --context kind-superlab wait --for=condition=Ready nodes --all --timeout=120s
echo '[ok] local superlab cluster is ready; no observability or GitOps addons installed'
