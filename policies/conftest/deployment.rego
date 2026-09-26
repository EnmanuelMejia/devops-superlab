# Checks rendered manifests before they reach a cluster:
#   kubectl kustomize kustomize/overlays/dev | conftest test -p policies/conftest -
# In the cluster, Gatekeeper (policies/gatekeeper) enforces the resource
# rules again at admission, and Pod Security "restricted" enforces the
# non-root and no-escalation rules. The registry and digest rules are
# checked here only.
package main

import rego.v1

# Kinds whose pod spec sits under spec.template.
template_kinds := {"Deployment", "StatefulSet", "DaemonSet", "ReplicaSet", "Job"}

pod_spec := input.spec.template.spec if input.kind in template_kinds

pod_spec := input.spec.jobTemplate.spec.template.spec if input.kind == "CronJob"

pod_spec := input.spec if input.kind == "Pod"

# Init containers run the same images with the same privileges, so they get
# the same rules as the main containers.
containers contains c if some c in pod_spec.containers

containers contains c if some c in pod_spec.initContainers

subject := sprintf("%s/%s", [input.kind, input.metadata.name])

deny contains msg if {
	some c in containers
	not startswith(c.image, "ghcr.io/")
	msg := sprintf("%s: container %q must pull from ghcr.io (got %q)", [subject, c.name, c.image])
}

deny contains msg if {
	some c in containers
	not contains(c.image, "@sha256:")
	msg := sprintf("%s: container %q must pin its image by digest (got %q)", [subject, c.name, c.image])
}

deny contains msg if {
	some c in containers
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
	some c in containers
	not c.securityContext.allowPrivilegeEscalation == false
	msg := sprintf("%s: container %q must set allowPrivilegeEscalation: false", [subject, c.name])
}
