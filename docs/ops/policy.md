# Policy

The lab enforces the same rules at two points, so a bad manifest fails in CI before it can fail in a cluster.

## In CI: Conftest

`policies/conftest/deployment.rego` (Rego v1) checks every workload in the rendered overlays:

- images come from `ghcr.io` and are pinned by digest;
- every container sets CPU and memory requests and limits;
- pods run as non-root and containers cannot escalate privileges.

`policies/conftest/deployment_test.rego` holds the unit tests.

```bash
conftest verify -p policies/conftest
kubectl kustomize kustomize/overlays/dev | conftest test -p policies/conftest -
```

`make validate` runs both for every overlay.

## At admission: Gatekeeper

`make gatekeeper-bootstrap` installs Gatekeeper v3.23.1 and two templates from the Gatekeeper policy library (`K8sContainerLimits`, `K8sContainerRequests`). The lab's constraints in `policies/gatekeeper/constraints` require requests and limits under a ceiling for every container in `superlab-*` namespaces; cluster add-ons are out of scope.

```bash
make gatekeeper-bootstrap
make policy-test   # a pod without requests or limits must be rejected
```

## Pod Security Admission

Every lab namespace is labelled `pod-security.kubernetes.io/enforce: restricted`, so Kubernetes itself rejects privileged or root pods there.
