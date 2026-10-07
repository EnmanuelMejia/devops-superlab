# Argo CD integration example

The files under `gitops/argocd/install/` contain namespace scaffolding; they do **not** install Argo CD controllers or CRDs. Accordingly, `make argocd-bootstrap` stops with a prerequisite message.

The application example points at the repository's dev overlay. It does not load the local Docker image into kind. Complete the [quickstart](../quickstart.md), then install a pinned Argo CD release using its official procedure in the disposable lab before applying this example.

The example uses manual sync. Review the rendered manifests and target namespace before syncing; no automatic prune or self-heal behavior is enabled. This is a planned integration exercise, not evidence of an operating GitOps environment.
