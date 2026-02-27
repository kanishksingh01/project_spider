Param(
  [string]$ClusterName = "spider-dev"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
  throw "Required command not found: kind"
}

kind delete cluster --name $ClusterName
