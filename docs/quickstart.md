# Quickstart

## Prerequisites

For tests only, use Python 3.13+ and Bash (Git Bash or WSL on Windows). The full exercise also requires a running Docker engine, kind, kubectl with Kustomize support, and make. Inspect the scripts before executing cluster operations.

```bash
make test
make build-images
make kind-up
kind load docker-image ghcr.io/enmanuelmejia/devops-superlab/health-demo:lab --name superlab
make kustomize-dev
kubectl --context kind-superlab -n superlab-dev get deploy,svc
kubectl --context kind-superlab -n superlab-dev port-forward service/health-demo 8080:8080
```

In a second terminal:

```bash
curl http://127.0.0.1:8080/health
# Expected JSON: {"status": "ok"}
```

The image stays local. `imagePullPolicy: Never` makes a missing `kind load` step fail visibly instead of silently fetching an unrelated image. The apply script waits for the deployment rollout and always names `kind-superlab`; it never relies on the current kubectl context.

All three overlays use the same local image and one replica. The prod name is a practice label; it is not a production environment. No external ingress, registry publish, Argo CD controller, metrics server, or monitoring stack is required or installed.

## Windows checks without a cluster

```powershell
python -m unittest discover -s samples/health-service -p "test_*.py" -v
python -m unittest discover -s tests -p "test_*.py" -v
kubectl kustomize kustomize/overlays/dev
```

The context tests locate Git Bash when Bash is not on PATH. Optional tests for future service directories run only when those directories exist; their failures stop the test runner.

## Cleanup

Stop port-forward with Ctrl+C, then run `make kind-down`. This deletes the explicitly named disposable `superlab` cluster. It does not remove unrelated clusters or images.
