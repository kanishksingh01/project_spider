# Spider

Project Spider is a declarative Kubernetes operations repository for managing cluster lifecycle, add-ons, and tenant workloads.

This repo includes:
- a deployable tenant service (`spider-api`)
- dev/prod Kubernetes manifests under `clusters/`
- local Docker smoke testing
- local cluster bootstrap scripts (`kind` + `kubectl`)

## What you can do right now

1. Run `spider-api` in Docker locally.
2. Create a local Kubernetes cluster.
3. Deploy `spider-api` to that cluster from Spider manifests.
4. Validate everything with copy/paste commands.

## Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose v2)
- `kubectl`
- `kind`
- Python 3.12+ (optional, for lint tooling)
- GNU Make (optional)

### Install commands

Windows (PowerShell):

```powershell
winget install -e --id Docker.DockerDesktop
winget install -e --id Kubernetes.kubectl
winget install -e --id Kubernetes.kind
```

macOS (Homebrew):

```bash
brew install --cask docker
brew install kubectl kind
```

Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y docker.io curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

Verify tools:

```bash
docker info
docker compose version
kubectl version --client
kind version
```

## Quick start: Docker-only run

From repo root:

```bash
git clone https://github.com/kanishksingh01/project_spider.git
cd project_spider
docker compose up --build -d
```

Check service:

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

Stop:

```bash
docker compose down --remove-orphans
```

## Build a Kubernetes cluster with Spider and deploy the app

This is the full flow to have Spider create a local cluster and deploy `spider-api`.

### Option A: One command script (recommended)

Windows PowerShell:

```powershell
git clone https://github.com/kanishksingh01/project_spider.git
cd project_spider
powershell -ExecutionPolicy Bypass -File .\scripts\cluster-up.ps1
```

macOS/Linux:

```bash
git clone https://github.com/kanishksingh01/project_spider.git
cd project_spider
bash ./scripts/cluster-up.sh
```

What the script does:
- creates a `kind` cluster named `spider-dev` (if missing)
- builds `spider-api:local`
- loads image into the cluster
- applies `clusters/dev/cluster-a`
- waits for rollout success

### Option B: Manual copy/paste commands

```bash
git clone https://github.com/kanishksingh01/project_spider.git
cd project_spider
kind create cluster --name spider-dev --wait 120s
docker build -t spider-api:local apps/tenants/spider-api
kind load docker-image spider-api:local --name spider-dev
kubectl config use-context kind-spider-dev
kubectl apply -k clusters/dev/cluster-a
kubectl -n spider-dev rollout status deployment/spider-api --timeout=180s
```

### Test the app in the cluster

Terminal 1:

```bash
kubectl -n spider-dev port-forward svc/spider-api 8080:80
```

Terminal 2:

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

## Teardown

Delete local deployment stack:

```bash
docker compose down --remove-orphans
```

Delete local kind cluster:

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\cluster-down.ps1
```

macOS/Linux:

```bash
bash ./scripts/cluster-down.sh
```

Manual equivalent:

```bash
kind delete cluster --name spider-dev
```

## Smoke test command

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1
```

## Makefile shortcuts (optional)

If `make` is installed:

```bash
make help
make docker-build
make docker-test
make cluster-up
make cluster-down
make manifests
make validate
```

## Validation and linting

Manifest render checks:

```bash
kubectl kustomize clusters/dev/cluster-a
kubectl kustomize clusters/prod/cluster-b
```

Install linter:

```bash
pip install yamllint
```

Run lint:

```bash
yamllint --strict .
```

## CI

`pipelines/github-actions/ci.yaml` runs:
- YAML lint (`yamllint --strict`)
- Kustomize build for dev/prod cluster manifests
- Docker build for `apps/tenants/spider-api`
- deployment smoke test against `/healthz`
