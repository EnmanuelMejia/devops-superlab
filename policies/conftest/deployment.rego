# Checks rendered manifests before they reach a cluster:
#   kubectl kustomize kustomize/overlays/dev | conftest test -p policies/conftest -
# The same resource rules are enforced at admission time by Gatekeeper
# (policies/gatekeeper), so a bad manifest fails in CI and in the cluster.
package main

import rego.v1

workload_kinds := {"Deployment", "StatefulSet", "DaemonSet", "Job"}

pod_spec := input.spec.template.spec if input.kind in workload_kinds

subject := sprintf("%s/%s", [input.kind, input.metadata.name])

deny contains msg if {
	some c in pod_spec.containers
	not startswith(c.image, "ghcr.io/")
	msg := sprintf("%s: container %q must pull from ghcr.io (got %q)", [subject, c.name, c.image])
}

deny contains msg if {
	some c in pod_spec.containers
	not contains(c.image, "@sha256:")
	msg := sprintf("%s: container %q must pin its image by digest (got %q)", [subject, c.name, c.image])
}

deny contains msg if {
	some c in pod_spec.containers
	some section in ["requests", "limits"]
	some resource in ["cpu", "memory"]
	not c.resources[section][resource]
	msg := sprintf("%s: container %q must set resources.%s.%s", [subject, c.name, section, resource])
}

deny contains msg if {
	pod_spec
	not pod_spec.securityContext.runAsNonRoot
	msg := sprintf("%s: pod must set securityContext.runAsNonRoot: true", [subject])
}

deny contains msg if {
	some c in pod_spec.containers
	not c.securityContext.allowPrivilegeEscalation == false
	msg := sprintf("%s: container %q must set allowPrivilegeEscalation: false", [subject, c.name])
}
