# Observability (optional)

`make observability-up` installs kube-prometheus-stack (Prometheus, Alertmanager, Grafana and the default Kubernetes dashboards) with the lab values in `observability/`, then applies a PodMonitor so Prometheus scrapes podinfo's metrics in every lab namespace. It needs Helm and noticeably more memory than the rest of the lab.

```bash
make observability-up
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
kubectl -n monitoring get secret monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d
```

`scripts/observability-check.sh` confirms Prometheus reports the podinfo targets as up. Logs and traces are not part of the lab.
