#!/usr/bin/env bash
# Offline checks, no cluster needed: render every overlay, validate it
# against the Kubernetes schemas, and test it against the lab's policy.
# Used by `make validate` and CI.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

echo "==> policy unit tests"
conftest verify --policy policies/conftest

for env in dev stage prod; do
  echo "==> overlay: ${env}"
  kubectl kustomize "kustomize/overlays/${env}" > "${out}/${env}.yaml"
  kubeconform -strict -summary "${out}/${env}.yaml"
  conftest test --policy policies/conftest "${out}/${env}.yaml"
done

echo "==> Argo CD application"
kubeconform -strict -summary \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  gitops/argocd/apps

echo "==> cluster add-ons render"
for dir in cluster/metrics-server gitops/argocd/install policies/gatekeeper/install policies/gatekeeper/templates; do
  kubectl kustomize "$dir" > /dev/null
  echo "rendered ${dir}"
done

echo "[ok] all overlays valid and policy-compliant"
