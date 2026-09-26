# Workload

The lab deploys [podinfo](https://github.com/stefanprodan/podinfo), a small Go web service built for exercising Kubernetes platforms. It is pinned by tag and digest (`6.15.0@sha256:ec73…`).

## Base (`kustomize/base`)

- **Deployment:** HTTP on 9898, Prometheus metrics on 9797, `/healthz` liveness and `/readyz` readiness probes, zero-downtime rolling updates.
- **Security context:** non-root (the image's own UID 100), read-only root filesystem, no privilege escalation, all capabilities dropped, `RuntimeDefault` seccomp, no service-account token.
- **Service:** ClusterIP for HTTP and metrics.
- **HorizontalPodAutoscaler:** targets 80% of requested CPU.

## Overlays (`kustomize/overlays`)

| | dev | stage | prod |
| --- | --- | --- | --- |
| Namespace | `superlab-dev` | `superlab-stage` | `superlab-prod` |
| Replicas | 1 | 2 | 3 |
| Autoscaling | 1–3 | 2–4 | 3–6 |
| Requests / limits | 50m, 64Mi / 500m, 128Mi | same as dev | 100m, 96Mi / 1 CPU, 256Mi |
| Extras | | | PodDisruptionBudget (minAvailable 2), topology spread across nodes |

Every namespace enforces the Pod Security "restricted" profile. Each environment shows its own message in the podinfo UI, which `make smoke` checks.
