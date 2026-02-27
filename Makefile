.DEFAULT_GOAL := help

.PHONY: help lint manifests validate docker-build docker-up docker-down docker-test cluster-up cluster-down

help:
	@echo "Available targets:"
	@echo "  make lint         - Run YAML lint checks"
	@echo "  make manifests    - Render dev/prod Kubernetes manifests"
	@echo "  make validate     - Run lint + manifest checks"
	@echo "  make docker-build - Build spider-api Docker image"
	@echo "  make docker-up    - Start local docker-compose stack"
	@echo "  make docker-down  - Stop local docker-compose stack"
	@echo "  make docker-test  - Run Docker deployment smoke test"
	@echo "  make cluster-up   - Create local kind cluster and deploy spider-api"
	@echo "  make cluster-down - Delete local kind cluster"

lint:
	yamllint --strict .

manifests:
	kubectl kustomize clusters/dev/cluster-a > /dev/null
	kubectl kustomize clusters/prod/cluster-b > /dev/null

validate: lint manifests

docker-build:
	docker build -t spider-api:local apps/tenants/spider-api

docker-up:
	docker compose up --build -d

docker-down:
	docker compose down --remove-orphans

docker-test:
	powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1

cluster-up:
	powershell -ExecutionPolicy Bypass -File .\scripts\cluster-up.ps1

cluster-down:
	powershell -ExecutionPolicy Bypass -File .\scripts\cluster-down.ps1
