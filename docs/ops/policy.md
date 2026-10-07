# Policy examples

The runnable deployment includes resource requests/limits and restricted container settings directly in its manifests. It does not depend on a policy controller.

The Gatekeeper file is an example constraint. Its controller, CRDs, and `K8sRequiredResources` constraint template are not bundled, so `make gatekeeper-bootstrap` stops with an explanation. Install a pinned upstream controller and matching template in the disposable lab before evaluating it.

The Conftest starter rule expects plain Kubernetes Deployment manifests and restricts container images to `ghcr.io/`. Use a current Rego v1-compatible Conftest installation:

```bash
kubectl kustomize kustomize/overlays/dev | conftest test -p policies/conftest -
```

The included Rego tests cover an allowed registry, a denied registry, and non-Deployment input; CI runs them with a pinned, checksum-verified OPA binary. Controller enforcement and a live Conftest run remain separate verification steps.
