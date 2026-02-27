Param(
  [string]$ClusterName = "spider-dev",
  [string]$Namespace = "spider-dev",
  [string]$ProfilePath = "clusters/dev/cluster-a"
)

$ErrorActionPreference = "Stop"

function Require-Command {
  Param([Parameter(Mandatory = $true)][string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $Name"
  }
}

Require-Command -Name docker
Require-Command -Name kind
Require-Command -Name kubectl

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "Docker daemon is not reachable. Start Docker Desktop (or Docker Engine) and retry."
}

$clusters = kind get clusters
if ($clusters -notcontains $ClusterName) {
  Write-Host "Creating kind cluster: $ClusterName"
  kind create cluster --name $ClusterName --wait 120s
}

Write-Host "Building spider-api image"
docker build -t spider-api:local apps/tenants/spider-api

Write-Host "Loading image into kind cluster: $ClusterName"
kind load docker-image spider-api:local --name $ClusterName

$context = "kind-$ClusterName"
kubectl config use-context $context | Out-Null

Write-Host "Applying manifests from $ProfilePath"
kubectl apply -k $ProfilePath

Write-Host "Waiting for rollout"
kubectl -n $Namespace rollout status deployment/spider-api --timeout=180s

Write-Host ""
Write-Host "Cluster is ready."
Write-Host "To test locally, run:"
Write-Host "  kubectl -n $Namespace port-forward svc/spider-api 8080:80"
Write-Host "Then open:"
Write-Host "  http://localhost:8080/healthz"
