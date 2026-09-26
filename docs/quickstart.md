# Quickstart

You need Docker, `make` and `bash`. Helm is only needed for the optional observability stack.

1. **Tools.** On Linux x86_64, install the pinned CLI versions CI uses (checksum-verified) into `./.bin`:
   ```bash
   make tools
   ```
   Elsewhere, install kubectl, kind, kubeconform and conftest with your package manager.

2. **Offline checks.** Render every overlay, validate it against the Kubernetes schemas, and test it against the lab policy:
   ```bash
   make validate
   ```

3. **Cluster.** Create the kind cluster and install metrics-server:
   ```bash
   make kind-up
   ```

4. **Deploy an environment** and check it end to end:
   ```bash
   make deploy ENV=dev        # or stage / prod
   make smoke ENV=dev
   kubectl -n superlab-dev get deploy,svc,hpa
   ```
   Open the app with `kubectl -n superlab-dev port-forward svc/podinfo 9898:9898`, then browse to <http://localhost:9898>.

5. **Admission policy.** Install Gatekeeper and prove it rejects a pod without requests or limits:
   ```bash
   make gatekeeper-bootstrap
   make policy-test
   ```

6. **GitOps.** Install Argo CD and let it sync the dev overlay from GitHub:
   ```bash
   make argocd-bootstrap
   ```

7. **Clean up:**
   ```bash
   make kind-down
   ```
