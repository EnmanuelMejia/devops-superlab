# Unit tests for deployment.rego. Run with: conftest verify -p policies/conftest
package main

import rego.v1

good_container := {
	"name": "app",
	"image": "ghcr.io/example/app:1.0.0@sha256:0000000000000000000000000000000000000000000000000000000000000000",
	"resources": {
		"requests": {"cpu": "50m", "memory": "64Mi"},
		"limits": {"cpu": "500m", "memory": "128Mi"},
	},
	"securityContext": {"allowPrivilegeEscalation": false},
}

deployment_with(container) := {
	"kind": "Deployment",
	"metadata": {"name": "app"},
	"spec": {"template": {"spec": {
		"securityContext": {"runAsNonRoot": true},
		"containers": [container],
	}}},
}

test_compliant_deployment_passes if {
	count(deny) == 0 with input as deployment_with(good_container)
}

test_non_ghcr_image_denied if {
	c := object.union(good_container, {"image": "docker.io/library/nginx:1.29@sha256:0000000000000000000000000000000000000000000000000000000000000000"})
	some msg in deny with input as deployment_with(c)
	contains(msg, "must pull from ghcr.io")
}

test_tag_only_image_denied if {
	c := object.union(good_container, {"image": "ghcr.io/example/app:latest"})
	some msg in deny with input as deployment_with(c)
	contains(msg, "must pin its image by digest")
}

test_missing_limits_denied if {
	c := json.patch(good_container, [{"op": "remove", "path": "/resources/limits"}])
	denials := deny with input as deployment_with(c)
	some msg in denials
	contains(msg, "resources.limits.cpu")
	some msg2 in denials
	contains(msg2, "resources.limits.memory")
}

test_root_pod_denied if {
	d := deployment_with(good_container)
	root := json.patch(d, [{"op": "replace", "path": "/spec/template/spec/securityContext", "value": {}}])
	some msg in deny with input as root
	contains(msg, "runAsNonRoot")
}

test_privilege_escalation_denied if {
	c := object.union(good_container, {"securityContext": {"allowPrivilegeEscalation": true}})
	some msg in deny with input as deployment_with(c)
	contains(msg, "allowPrivilegeEscalation")
}

test_init_containers_checked if {
	d := deployment_with(good_container)
	init := {"name": "setup", "image": "docker.io/library/busybox:latest"}
	with_init := json.patch(d, [{"op": "add", "path": "/spec/template/spec/initContainers", "value": [init]}])
	denials := deny with input as with_init
	some m1 in denials
	contains(m1, "container \"setup\" must pull from ghcr.io")
	some m2 in denials
	contains(m2, "container \"setup\" must pin its image by digest")
	some m3 in denials
	contains(m3, "container \"setup\" must set resources.limits.memory")
	some m4 in denials
	contains(m4, "container \"setup\" must set allowPrivilegeEscalation: false")
}

test_compliant_cronjob_passes if {
	d := deployment_with(good_container)
	cron := {
		"kind": "CronJob",
		"metadata": {"name": "nightly"},
		"spec": {"jobTemplate": {"spec": {"template": d.spec.template}}},
	}
	count(deny) == 0 with input as cron
}

test_cronjob_checked if {
	c := object.union(good_container, {"image": "docker.io/library/busybox:latest"})
	d := deployment_with(c)
	cron := {
		"kind": "CronJob",
		"metadata": {"name": "nightly"},
		"spec": {"jobTemplate": {"spec": {"template": d.spec.template}}},
	}
	some msg in deny with input as cron
	contains(msg, "CronJob/nightly: container \"app\" must pull from ghcr.io")
}

test_bare_pod_checked if {
	pod := {
		"kind": "Pod",
		"metadata": {"name": "debug"},
		"spec": {"containers": [object.union(good_container, {"securityContext": {"allowPrivilegeEscalation": true}})]},
	}
	denials := deny with input as pod
	some m1 in denials
	contains(m1, "Pod/debug: pod must set securityContext.runAsNonRoot")
	some m2 in denials
	contains(m2, "Pod/debug: container \"app\" must set allowPrivilegeEscalation: false")
}

test_non_workloads_ignored if {
	count(deny) == 0 with input as {"kind": "Service", "metadata": {"name": "app"}, "spec": {}}
}
