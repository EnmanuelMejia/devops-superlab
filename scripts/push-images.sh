#!/usr/bin/env bash
# Build and push service images to GHCR (linux/amd64).
# Services that are not in this checkout are skipped and reported, so CI only
# claims the images it actually built. Log in to GHCR before running locally:
#   docker login ghcr.io -u EnmanuelMejia --password-stdin
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
  echo "==> buildx + push $s"
  docker buildx build --platform linux/amd64 -t "$IMG_BASE/$s:latest" "$ROOT/services/$s" --push
  built=$((built + 1))
done
echo "[ok] pushed $built image(s)"
