# DevOps SuperLab

A personal practice repository by [Enmanuel Mejia](https://github.com/EnmanuelMejia), pursuing junior cloud and DevOps roles with an IT support background. This lab provides inspectable exercises and starter designs; it does not represent a customer deployment or paid production ownership.

## Start with the implemented exercise

The included Python health service has HTTP tests, a non-root Dockerfile, resource limits, health probes, and Kustomize overlays for a disposable local kind cluster. The names `dev`, `stage`, and `prod` are **practice namespaces on the same local cluster**.

```bash
# Python 3.13+, Bash, Docker, kind, kubectl, and make required for the whole flow.
make test
make build-images
make kind-up
kind load docker-image ghcr.io/enmanuelmejia/devops-superlab/health-demo:lab --name superlab
make kustomize-dev
kubectl --context kind-superlab -n superlab-dev port-forward service/health-demo 8080:8080
# In a second terminal: curl http://127.0.0.1:8080/health
# When finished: stop port-forward, then make kind-down
```

Tests run without Docker or a Kubernetes cluster. See the [quickstart](docs/quickstart.md) for Windows checks, prerequisites, expected output, and cleanup.

## Implemented and planned scope

| Area | Current source |
| --- | --- |
| Runnable sample | Standard-library Python health service; four real HTTP tests |
| Local Kubernetes | One deployment/service; three namespace overlays; context-guarded apply scripts |
| Verification | Service tests, mocked context safety checks, shell syntax, YAML/docs validation, image build in CI |
| Documentation | [Published guide](https://enmanuelmejia.github.io/devops-superlab/) and [Labs overview](https://interstitiumlabs.dev/labs/superlab/) |
| GitOps | Argo CD application example; controller and CRDs require a separate verified installation |
| Policy | Conftest starter rule and Gatekeeper example; controller and constraint template are not bundled |
| Observability | Architecture notes; no dashboards or monitoring stack installed by the quickstart |
| Future services | Node, Go, .NET, Spring, gateway, and frontend designs; source is not yet included |

The security workflow emits scan reports; a successful scan run is not proof that every finding was fixed. No registry login, image push, cloud deployment, or production cluster action occurs in pull-request CI.

## Repository map

- [samples/health-service/](samples/health-service/): implemented local exercise.
- [kustomize/](kustomize/): base and local namespace overlays.
- [scripts/](scripts/): tests, local image build, and guarded cluster operations.
- [docs/](docs/): learning path and integration boundaries.
- [gitops/](gitops/) and [policies/](policies/): examples with documented prerequisites.
- [.github/workflows/](.github/workflows/): verification, scans, documentation, and optional future Helm release.

The optional Fish scripts depend on private machine-local helpers; they are excluded from the portable quickstart. Terraform, HA, autoscaling, multi-service tracing, full GitOps automation, and production operations remain learning goals rather than completed claims.

## Author and contact

[Portfolio](https://enmanueldmejia.com/) · [GitHub](https://github.com/EnmanuelMejia) · [LinkedIn](https://www.linkedin.com/in/enmanuelmejia) · [mejiaenmanueld@gmail.com](mailto:mejiaenmanueld@gmail.com)

## License

No license file yet — all rights reserved unless/until an SPDX license is added.
