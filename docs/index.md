# DevOps SuperLab

A Kubernetes, GitOps, CI/CD and policy-as-code lab, built so every claim can be run and checked.

> Portfolio lab, not a paid production deployment. It exists to demonstrate cloud and DevOps skills clearly in interviews.

## Highlights

- **Environments:** dev, stage and prod Kustomize overlays over one workload ([podinfo](https://github.com/stefanprodan/podinfo)), with autoscaling, a disruption budget and topology spread in prod.
- **Security by default:** every lab namespace enforces Pod Security "restricted"; the workload runs non-root with a read-only root filesystem and no Linux capabilities.
- **Policy twice:** Conftest checks rendered manifests in CI; Gatekeeper rejects non-compliant pods at admission.
- **GitOps:** Argo CD keeps the dev environment in sync with `main`.
- **Proven in CI:** a GitHub Actions workflow creates a kind cluster, deploys every overlay, smoke-tests dev, proves the admission policy and waits for Argo CD to sync.

## Quick peek

```bash
make tools
make kind-up
make deploy ENV=dev
make smoke ENV=dev
```
