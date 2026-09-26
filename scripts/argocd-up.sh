#!/usr/bin/env bash
# Install Argo CD and let it sync kustomize/overlays/dev from GitHub.
#   REVISION=<branch> ./scripts/argocd-up.sh   # default: main
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
REVISION="${REVISION:-main}"

echo "==> Argo CD"
# Server-side apply: the ApplicationSet CRD is too large for client-side apply.
kubectl apply --server-side --force-conflicts -k gitops/argocd/install
kubectl wait --for=condition=established crd/applications.argoproj.io --timeout=120s
for d in argocd-server argocd-repo-server argocd-applicationset-controller argocd-redis; do
  kubectl -n argocd rollout status "deploy/${d}" --timeout=300s
done
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

echo "==> application superlab-dev tracking ${REVISION}"
sed "s#targetRevision: main#targetRevision: ${REVISION}#" gitops/argocd/apps/superlab-dev.yaml | kubectl apply -f -
kubectl -n argocd wait application/superlab-dev --for=jsonpath='{.status.sync.status}'=Synced --timeout=300s
kubectl -n argocd wait application/superlab-dev --for=jsonpath='{.status.health.status}'=Healthy --timeout=300s
echo "[ok] Argo CD synced superlab-dev from ${REVISION}"
echo "UI: kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
