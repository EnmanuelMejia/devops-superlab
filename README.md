# DevOps SuperLab

[![CI](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/ci.yml/badge.svg)](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/ci.yml)
[![Lab e2e](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/lab-e2e.yml/badge.svg)](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/lab-e2e.yml)
[![Security-Scans](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/security.yml/badge.svg)](https://github.com/EnmanuelMejia/devops-superlab/actions/workflows/security.yml)

**Portfolio lab (not paid production)**: a Kubernetes, GitOps, CI/CD and policy-as-code lab by [Enmanuel Mejia](https://github.com/EnmanuelMejia), built so every claim below can be run and checked.

The lab deploys a small real service, [podinfo](https://github.com/stefanprodan/podinfo), to a local kind cluster through Kustomize overlays. It enforces the same resource and security rules twice: in CI with Conftest, and at admission time with Gatekeeper. Argo CD keeps the dev environment in sync with `main`, and a GitHub Actions workflow builds the whole lab in a throwaway cluster on every change.

> This repository demonstrates hands-on cloud/DevOps skills beyond paid IT operations experience. It is **not** a customer production deployment.

## What you can demo

| Area | What's in the repo | Checked by |
| --- | --- | --- |
| Local cluster | kind with 1 control plane and 2 workers, plus metrics-server (`make kind-up`) | Lab e2e |
| Workload | podinfo with probes, an HPA, and a pod spec that passes Pod Security "restricted" (`kustomize/base`) | Lab e2e |
| Environments | dev, stage and prod overlays: namespace, replicas, autoscaling range, resources; prod adds a PDB and topology spread | CI, Lab e2e |
| Policy in CI | Conftest (Rego v1) with unit tests: ghcr.io only, digest-pinned images, requests and limits, non-root, no privilege escalation | CI |
| Policy at admission | Gatekeeper with library templates enforcing requests and limits in `superlab-*` namespaces | Lab e2e rejects a non-compliant pod |
| GitOps | Argo CD (pinned upstream install) syncing `kustomize/overlays/dev` from GitHub | Lab e2e waits for Synced and Healthy |
| Observability (optional) | kube-prometheus-stack; Prometheus scrapes podinfo through a PodMonitor | Lab e2e, manual run |
| CI/CD | pre-commit lint, offline validation, kind e2e, Trivy and Checkov scans, MkDocs to GitHub Pages | GitHub Actions |
| Supply chain | Actions pinned to commit SHAs, tools pinned by SHA-256, the image pinned by digest | CI |

## Quickstart

Needs Docker, `make` and `bash`. `make tools` installs the pinned kubectl, kind, kubeconform and conftest into `./.bin` on Linux x86_64; elsewhere, install them with your package manager.

```bash
make tools                   # pinned CLI tools, checksum-verified
make validate                # offline: render overlays, check schemas and policy

make kind-up                 # kind cluster + metrics-server
make deploy ENV=dev          # or stage / prod
make smoke ENV=dev           # health, readiness, the env's message, live HPA metrics

make gatekeeper-bootstrap    # admission policy for superlab-* namespaces
make policy-test             # a pod without requests or limits is rejected

make argocd-bootstrap        # Argo CD syncs the dev overlay from main
make observability-up        # optional: Prometheus, Alertmanager, Grafana (needs Helm)

make kind-down
```

Full walkthrough: [`docs/quickstart.md`](docs/quickstart.md) · site config: [`mkdocs.yml`](mkdocs.yml)

## Repository map

```
kustomize/base/           podinfo Deployment, Service, HPA
kustomize/overlays/       dev, stage, prod
cluster/                  kind config, metrics-server (pinned)
policies/conftest/        Rego policy and its unit tests, run in CI
policies/gatekeeper/      Gatekeeper install, library templates, lab constraints
gitops/argocd/            Argo CD install (pinned) and the dev Application
observability/            optional kube-prometheus-stack values and PodMonitor
scripts/                  everything the Makefile and CI run
.github/workflows/        CI, Lab e2e, Security-Scans, Docs
docs/                     MkDocs site
```

## Honest scope (important for recruiters)

- **Is:** a structured portfolio lab for demos and interviews. Every row in the table above runs in GitHub Actions.
- **Is not:** evidence of paid production ownership at an employer.
- podinfo is a third-party demo service by Stefan Prodan. The lab's own work is the platform around it: environments, policy, GitOps, automation and CI.
- `scripts/self-test.fish` and `scripts/git-publish.fish` are machine-local helpers from the original workstation setup. They are not part of the lab.

## Stack

Kubernetes · kind · Kustomize · Argo CD · Gatekeeper · Conftest / Rego · Pod Security Admission · GitHub Actions · Prometheus / Grafana (optional) · Helm · Trivy · Checkov · MkDocs · Linux

## Author

**Enmanuel Mejia** — Junior Cloud / DevOps candidate
Orlando, FL · targeting Boston · Orlando · Miami–Fort Lauderdale · Remote
Portfolio: https://enmanueldmejia.com
GitHub: https://github.com/EnmanuelMejia
Lab site: https://interstitiumlabs.dev/labs/superlab/
LinkedIn: https://www.linkedin.com/in/enmanuelmejia


## Interstitium Labs hub

Public Learning OS page for this lab (student quickstart, stack map, honest scope):

**https://interstitiumlabs.dev/labs/superlab/**

[![Interstitium Labs](https://img.shields.io/badge/Interstitium%20Labs-SuperLab%20hub-5eead4?style=flat-square&labelColor=070B16)](https://interstitiumlabs.dev/labs/superlab/)

## License

No license file yet — all rights reserved unless/until an SPDX license is added.
