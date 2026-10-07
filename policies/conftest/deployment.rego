package kubernetes.admission
import rego.v1

deny contains msg if {
  input.kind == "Deployment"
  some c in input.spec.template.spec.containers
  not startswith(c.image, "ghcr.io/")
  msg := sprintf("container %q must use ghcr.io registry (got: %q)", [c.name, c.image])
}
