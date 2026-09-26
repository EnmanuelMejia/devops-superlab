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

echo "==> a pod without requests or limits must be denied"
for _ in $(seq 1 30); do
  if out="$(probe 2>&1)"; then
    sleep 3  # constraints can take a few seconds to reach the webhook
  else
    echo "$out"
    grep -q 'superlab-container-limits' <<<"$out" && grep -q 'superlab-container-requests' <<<"$out" \
      && { denied=1; break; }
    echo "[fail] rejected, but not by the lab's constraints" >&2
    exit 1
  fi
done
[ "${denied:-0}" = 1 ] || { echo "[fail] Gatekeeper admitted a pod without requests or limits" >&2; exit 1; }

echo "==> a compliant rollout must still be admitted"
kubectl -n "$NS" rollout restart deploy/podinfo
kubectl -n "$NS" rollout status deploy/podinfo --timeout=180s
echo "[ok] admission policy enforced"
