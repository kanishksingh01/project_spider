# Spider

Project Spider is a declarative Kubernetes operations repository for managing cluster lifecycle, add-ons, and tenant workloads.

This repository includes:
- a minimal deployable tenant service (`spider-api`)
- valid Kustomize manifests for `dev` and `prod` sample clusters
- CI checks for YAML linting, Kustomize rendering, and Docker deployment smoke testing

## Repository layout

- `platform/terraform/`: cloud infrastructure definitions
- `platform/capi-management-cluster/`: management-cluster and GitOps bootstrap manifests
- `clusters/`: environment- and cluster-specific Kubernetes manifests
- `addons/`: shared cluster add-ons grouped by domain
- `apps/`: tenant applications and overlays
- `pipelines/`: CI/CD workflows
- `scripts/`: local automation scripts

## Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose v2)
- Docker daemon running
- `kubectl` (for `kubectl kustomize` validation)
- Python 3.12+ (for lint tooling and scripts)
- GNU Make (optional, for shortcut commands)

Quick checks:

```bash
docker info
docker compose version
kubectl version --client
python --version
```

## Quick start

1. Clone the repository:

```bash
git clone https://github.com/kanishksingh01/project_spider.git
cd project_spider
```

2. Build and run locally:

```bash
docker compose up --build -d
```

3. Verify service health.

macOS/Linux:

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/
```

Windows PowerShell:

```powershell
Invoke-WebRequest http://localhost:8080/healthz -UseBasicParsing
Invoke-WebRequest http://localhost:8080/ -UseBasicParsing
```

4. Stop local deployment:

```bash
docker compose down --remove-orphans
```

## One-command deployment smoke test

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1
```

What it does:
- builds and starts the Docker service
- waits for `/healthz`
- calls `/` and prints JSON response
- tears down containers and network automatically

## Makefile workflow (optional)

If `make` is installed:

```bash
make help
make docker-build
make docker-test
make manifests
make validate
```

## Kubernetes manifest validation

Render manifests (same target paths as CI):

```bash
kubectl kustomize clusters/dev/cluster-a
kubectl kustomize clusters/prod/cluster-b
```

## Linting

Install dependency:

```bash
pip install yamllint
```

Run lint:

```bash
yamllint --strict .
```

## Continuous Integration

`pipelines/github-actions/ci.yaml` runs:
- `yamllint --strict`
- `kustomize build` for:
  - `clusters/dev/cluster-a`
  - `clusters/prod/cluster-b`
- Docker image build for `apps/tenants/spider-api`
- deployment smoke test against `/healthz`
