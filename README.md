# DevOps SuperLab

**Portfolio lab (not paid production)** — an interview-ready Kubernetes / GitOps / CI/CD / IaC demo by [Enmanuel Mejia](https://github.com/EnmanuelMejia).

Built to walk hiring managers through a live stack: local kind cluster, Kustomize overlays, Argo CD, GitHub Actions, policy gates, and observability docs.

> This repository demonstrates hands-on cloud/DevOps skills beyond paid IT operations experience. It is **not** a customer production deployment.

## What you can demo

| Area | What’s in the repo |
| --- | --- |
| Local cluster | `kind` bootstrap + ingress / metrics (`make kind-up`) |
| Deploy | Kustomize-oriented Makefile targets for env apply flows |
| GitOps | Argo CD install manifests + app-of-apps |
| CI/CD | GitHub Actions: CI, security, docs, Kustomize validate, Helm OCI release |
| Policy | Gatekeeper constraints + Conftest Rego |
| Docs | MkDocs site (`docs/`) covering quickstart, GitOps, pipelines, ops |
| Supply chain hygiene | pre-commit, Renovate |

## Quickstart

```bash
# tooling hooks
make bootstrap

# local cluster
make kind-up

# apply a documented env flow (see Makefile / docs)
make kustomize-dev
kubectl -n superlab-dev get deploy,svc,hpa

# tear down
make kind-down
```

Full walkthrough: [`docs/quickstart.md`](docs/quickstart.md) · site config: [`mkdocs.yml`](mkdocs.yml)

## Repository map

```
.github/workflows/   CI, security scans, docs publish, validate, Helm OCI
docs/                Interview-oriented documentation (MkDocs)
gitops/argocd/       Argo CD install + app-of-apps
policies/            Gatekeeper + Conftest
scripts/             kind bootstrap, image build/push, tests, smoke checks
Makefile             Operator entrypoints
```

## Honest scope (important for recruiters)

- **Is:** a structured portfolio / lab for demos and interviews.
- **Is not:** evidence of paid production ownership at an employer.
- Scripts such as `scripts/self-test.fish` still assume some host-local helpers (for example `~/devops-status.fish`). Treat those as optional machine-local wiring; the documented `make` targets and `docs/` are the portable path.

## Stack

Kubernetes · kind · Kustomize · Helm · Argo CD · GitHub Actions · Docker/Buildx · Gatekeeper · Conftest · Prometheus/Grafana docs · Terraform (IaC practices in lab narrative) · Linux

## Author

**Enmanuel Mejia** — Junior Cloud / DevOps candidate
Orlando, FL · targeting Boston · Orlando · Miami–Fort Lauderdale · Remote
GitHub: https://github.com/EnmanuelMejia
Lab site: https://interstitiumlabs.dev/labs/superlab/
LinkedIn: https://www.linkedin.com/in/enmanuelmejia


## Interstitium Labs hub

Public Learning OS page for this lab (student quickstart, stack map, honest scope):

**https://interstitiumlabs.dev/labs/superlab/**

[![Interstitium Labs](https://img.shields.io/badge/Interstitium%20Labs-SuperLab%20hub-5eead4?style=flat-square&labelColor=070B16)](https://interstitiumlabs.dev/labs/superlab/)

## License

No license file yet — all rights reserved unless/until an SPDX license is added.
