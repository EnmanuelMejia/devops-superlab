#!/usr/bin/env bash
# Prove the admission policy works: a pod that passes Pod Security
# "restricted" but sets no resources must be rejected by Gatekeeper, and a
# compliant rollout must still be admitted. Run after gatekeeper-up.sh.
set -euo pipefail
NS="${NS:-superlab-dev}"
IMAGE="ghcr.io/stefanprodan/podinfo:6.15.0@sha256:ec73780a8425f59ea49f5bc8cdff0d598805a224fbaa1f86c67a244f250fa9da"

probe() {
  kubectl apply --dry-run=server -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: policy-probe
  namespace: ${NS}
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 100
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: probe
      image: ${IMAGE}
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
YAML
}

echo "==> a pod without requests or limits must be denied by both constraints"
# Constraints take a few seconds to reach the webhook, and Gatekeeper's
# webhook replicas load them independently, so an early denial may name only
# one of the two. Keep probing until a single denial names both.
denied=0
out=""
for _ in $(seq 1 40); do
  if ! out="$(probe 2>&1)" \
    && grep -q 'superlab-container-limits' <<<"$out" \
    && grep -q 'superlab-container-requests' <<<"$out"; then
    echo "$out"
    denied=1
    break
  fi
  sleep 3
done
if [ "$denied" != 1 ]; then
  echo "last response: ${out}" >&2
  echo "[fail] Gatekeeper did not reject a pod without requests or limits with both lab constraints" >&2
  exit 1
fi

echo "==> a compliant rollout must still be admitted"
kubectl -n "$NS" rollout restart deploy/podinfo
kubectl -n "$NS" rollout status deploy/podinfo --timeout=180s
echo "[ok] admission policy enforced"
