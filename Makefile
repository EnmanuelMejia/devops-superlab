SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# Pinned tools from `make tools` take precedence over whatever is on PATH.
export PATH := $(CURDIR)/.bin:$(PATH)

ENV ?= dev

help: ## show available targets
	@awk 'BEGIN{FS=":.*##"; printf "\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

tools: ## install pinned kubectl, kind, kubeconform and conftest into ./.bin (Linux x86_64)
	./scripts/install-tools.sh

bootstrap: ## install the pre-commit hooks
	pre-commit install

lint: ## run every pre-commit hook on every file
	pre-commit run --all-files

validate: ## offline: render overlays, check schemas and policy
	./scripts/validate.sh

kind-up: ## create the kind cluster and install metrics-server
	./scripts/kind-superlab-up.sh

kind-down: ## delete the kind cluster
	kind delete cluster --name superlab

deploy: ## apply one overlay and wait for it: make deploy ENV=dev|stage|prod
	kubectl apply -k kustomize/overlays/$(ENV)
	kubectl -n superlab-$(ENV) rollout status deploy/podinfo --timeout=180s

kustomize-dev: ## apply the dev overlay
	$(MAKE) deploy ENV=dev

kustomize-stage: ## apply the stage overlay
	$(MAKE) deploy ENV=stage

kustomize-prod: ## apply the prod overlay
	$(MAKE) deploy ENV=prod

smoke: ## check a deployed environment end to end: make smoke ENV=dev
	./scripts/smoke.sh $(ENV)

gatekeeper-bootstrap: ## install Gatekeeper and enforce requests/limits in superlab-* namespaces
	./scripts/gatekeeper-up.sh

policy-test: ## prove Gatekeeper rejects a pod without requests or limits
	./scripts/policy-e2e.sh

argocd-bootstrap: ## install Argo CD and sync the dev overlay from GitHub
	./scripts/argocd-up.sh

observability-up: ## optional: Prometheus, Alertmanager and Grafana, scraping podinfo
	./scripts/observability-up.sh

docs-serve: ## serve the MkDocs site locally
	mkdocs serve -a 0.0.0.0:8000

.PHONY: help tools bootstrap lint validate kind-up kind-down deploy kustomize-dev kustomize-stage kustomize-prod \
	smoke gatekeeper-bootstrap policy-test argocd-bootstrap observability-up docs-serve
