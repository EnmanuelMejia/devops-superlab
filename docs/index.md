# DevOps SuperLab

Interview-oriented **portfolio** stack for CI/CD, GitOps, Kustomize, HPAs, observability, and policy controls.

> Not a paid production deployment — built to demonstrate cloud/DevOps skills clearly in interviews.

## Highlights

- CI/CD → tests, Docker Buildx → GHCR, SBOMs & scans (Trivy / related security workflow)
- Kustomize-oriented env apply flows with HPA-oriented docs
- Helm / OCI release workflow
- kind bootstrap + metrics-server + ingress + observability docs (Prom/Grafana, Loki, Tempo, OTEL)
- GitOps (Argo CD), policy (Gatekeeper) + Conftest, pre-commit, Renovate

## Quick peek

```bash
make bootstrap
make kind-up
make kustomize-dev
kubectl -n superlab-dev get deploy,svc,hpa
```
