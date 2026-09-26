# Argo CD (GitOps)

`make argocd-bootstrap` installs Argo CD v3.5.3 from the upstream manifest (`gitops/argocd/install`) and applies one Application, `gitops/argocd/apps/superlab-dev.yaml`. It tracks `kustomize/overlays/dev` on `main` with automated sync, pruning and self-heal:

- a merged change to the dev overlay rolls out without anyone running `kubectl`;
- a manual edit in the cluster is reverted to what Git says.

```bash
make argocd-bootstrap
kubectl -n argocd get application superlab-dev
```

The UI:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

The Lab e2e workflow runs the same bootstrap against the branch under test and waits for the Application to report Synced and Healthy.
