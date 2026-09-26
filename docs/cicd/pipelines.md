# CI/CD Pipelines

Workflows live in `.github/workflows/`. Every third-party action is pinned to a commit SHA.

| Workflow | Runs on | What it does |
| --- | --- | --- |
| **CI** | every push and PR | `lint`: all pre-commit hooks (YAML syntax and style, ShellCheck, whitespace, merge markers). `validate`: installs checksum-verified kubectl, kubeconform and conftest, then renders each overlay, validates it against the Kubernetes schemas and tests it against the Rego policy. |
| **Lab e2e** | PRs and pushes that touch the lab, weekly, or by hand | Creates a kind cluster, deploys all three overlays, smoke-tests dev, installs Gatekeeper and proves it rejects a non-compliant pod, then installs Argo CD and waits for it to sync the dev overlay. A manual run can also install and check the observability stack. |
| **Security-Scans** | pushes to main and nightly | Trivy filesystem and configuration scans uploaded to GitHub code scanning, plus Checkov for infrastructure code. |
| **Docs** | changes under `docs/` | Builds this MkDocs site in strict mode and publishes it to GitHub Pages. |
