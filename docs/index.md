# DevOps SuperLab

A personal local lab for junior cloud and DevOps practice, built from an IT support background. It is not a customer production deployment.

Begin with the [quickstart](quickstart.md): test one Python health service, build its local image, and deploy it to a disposable kind cluster. The dev, stage, and prod overlay names represent local practice namespaces.

## Inspect the evidence

- Four HTTP tests cover health, scope, unknown paths, and unsupported write requests.
- Context safety tests exercise rejected inputs and failed cluster creation with mocked tools.
- Docker and Kubernetes sources use a non-root process, health probes, resource limits, and a read-only container filesystem.
- CI validates tests, shell syntax, YAML, documentation, overlay rendering, and an image build without registry writes.
- GitOps, policy controllers, and observability are integration examples or planned extensions, as labeled in their guides.

[Portfolio](https://enmanueldmejia.com/) · [Interstitium Labs overview](https://interstitiumlabs.dev/labs/superlab/) · [Public contact](mailto:mejiaenmanueld@gmail.com)
