#!/usr/bin/env bash
# Build service images locally (no push). Services that are not in this
# checkout are skipped and reported.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG_BASE="ghcr.io/enmanuelmejia/devops-superlab"  # registry paths must be lowercase
SERVICES=(api-gateway node-express go-chi dotnet-minimal spring-boot web-frontend)
built=0
for s in "${SERVICES[@]}"; do
  if [ ! -d "$ROOT/services/$s" ]; then
    echo "[skip] $s: services/$s is not in this repository"
    continue
  fi
  echo "==> building $s"
  docker build -t "$IMG_BASE/$s:dev" "$ROOT/services/$s"
  built=$((built + 1))
done
echo "[ok] built $built image(s)"
