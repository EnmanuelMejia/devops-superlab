SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

help: ## show available targets
	@awk 'BEGIN{FS=":.*##"} /^[a-zA-Z0-9_.-]+:.*##/{printf "  %-22s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

bootstrap: ## install optional pre-commit hooks
	pre-commit install -t pre-commit -t commit-msg

lint: ## run optional multi-language linters
	pre-commit run --all-files

test: ## run actual service and lab-context tests
	bash ./scripts/run-tests.sh

build-images: ## build the local health demo and any present optional service
	bash ./scripts/build-images.sh

push-images: ## explicit optional GHCR publish for future services
	bash ./scripts/push-images.sh

kustomize-dev: ## apply dev to the local kind-superlab context
	bash ./scripts/kustomize-apply.sh dev

kustomize-stage: ## apply stage to the local kind-superlab context
	bash ./scripts/kustomize-apply.sh stage

kustomize-prod: ## apply the prod practice namespace on local kind
	bash ./scripts/kustomize-apply.sh prod

kind-up: ## create or verify the disposable local superlab cluster
	bash ./scripts/kind-superlab-up.sh

kind-down: ## delete only the named disposable superlab cluster
	kind delete cluster --name superlab

argocd-bootstrap: ## show GitOps integration prerequisites
	@echo 'Argo CD controller/CRDs are not bundled. Read docs/gitops/argocd.md.'
	@exit 1

gatekeeper-bootstrap: ## show policy integration prerequisites
	@echo 'Gatekeeper controller/templates are not bundled. Read docs/ops/policy.md.'
	@exit 1

docs-serve: ## serve documentation on localhost
	mkdocs serve -a 127.0.0.1:8000
