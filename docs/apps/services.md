# Services

The implemented exercise is `samples/health-service`: a standard-library Python HTTP server with `GET /health`, `GET /`, a JSON 404, and no write API, storage, or authentication. Use it only for local practice.

Its Dockerfile runs as UID 10001. The Kubernetes deployment includes readiness/liveness probes, CPU and memory requests/limits, a read-only filesystem, dropped capabilities, and no mounted service-account token. The Service uses ClusterIP.

The [quickstart](../quickstart.md) deploys one replica to a local namespace. There is no HPA, public ingress, production SLA, or application telemetry. Frontend, gateway, Node, Go, .NET, and Spring services are future exercises whose source is not yet included.
