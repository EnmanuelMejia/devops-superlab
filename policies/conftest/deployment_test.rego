package kubernetes.admission
import rego.v1

test_allowed_registry if {
  count(deny) == 0 with input as {"kind": "Deployment", "spec": {"template": {"spec": {"containers": [{"name": "demo", "image": "ghcr.io/example/demo:lab"}]}}}}
}

test_denied_registry if {
  count(deny) == 1 with input as {"kind": "Deployment", "spec": {"template": {"spec": {"containers": [{"name": "demo", "image": "docker.io/example/demo:lab"}]}}}}
}

test_non_deployment_is_ignored if {
  count(deny) == 0 with input as {"kind": "Service"}
}
