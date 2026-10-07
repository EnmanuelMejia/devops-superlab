# CI/CD pipelines

The CI workflow runs actual service/context tests, shell syntax checks, YAML lint, a strict MkDocs build, client-side Kustomize rendering, three OPA registry-policy tests, and a local Docker image build. Pull requests have read-only repository permission; they do not log into GHCR, publish images, or deploy a cluster.

The security workflow publishes Trivy reports and runs Checkov with `soft_fail`. Its green status alone is not a pass/fail vulnerability gate or evidence that findings were remediated.

The documentation workflow builds before publishing GitHub Pages from main. A separate optional Helm release workflow anticipates future charts; no charts are currently included. Future services, SBOM publication, schema validation, and registry release gates require separate implementation and verification.
