# Local Cluster (kind)

`make kind-up` runs `scripts/kind-superlab-up.sh`, which is safe to re-run:

- creates the `superlab` cluster from `cluster/kind.yaml`: one control plane and two workers, so the prod overlay's topology spread and disruption budget have more than one node to work with;
- installs metrics-server v0.9.0 from `cluster/metrics-server`, which feeds the HorizontalPodAutoscalers. kind's kubelets use self-signed certificates, so the lab adds `--kubelet-insecure-tls`. Do not copy that flag to a real cluster.

```bash
make kind-up
kubectl get nodes
make kind-down
```

There is no ingress controller; reach services with `kubectl port-forward`.
