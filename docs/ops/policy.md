# Policy

Every rule is checked in CI, so a bad manifest fails before it reaches a cluster. The cluster then enforces most of them again at admission:

| Rule | In CI | At admission |
| --- | --- | --- |
| CPU and memory requests and limits | Conftest | Gatekeeper |
| Non-root, no privilege escalation | Conftest | Pod Security "restricted" |
| Images from `ghcr.io`, pinned by digest | Conftest | not enforced |

## In CI: Conftest

`policies/conftest/deployment.rego` (Rego v1) checks every Deployment, StatefulSet, DaemonSet, ReplicaSet, Job, CronJob and bare Pod in the rendered overlays, init containers included:

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
