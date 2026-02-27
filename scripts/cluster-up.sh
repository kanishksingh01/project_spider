#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-spider-dev}"
NAMESPACE="${2:-spider-dev}"
PROFILE_PATH="${3:-clusters/dev/cluster-a}"
CONTEXT="kind-${CLUSTER_NAME}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

require_cmd docker
require_cmd kind
require_cmd kubectl

docker info >/dev/null

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Creating kind cluster: ${CLUSTER_NAME}"
  kind create cluster --name "${CLUSTER_NAME}" --wait 120s
fi

echo "Building spider-api image"
docker build -t spider-api:local apps/tenants/spider-api

echo "Loading image into kind cluster: ${CLUSTER_NAME}"
kind load docker-image spider-api:local --name "${CLUSTER_NAME}"

kubectl config use-context "${CONTEXT}" >/dev/null

echo "Applying manifests from ${PROFILE_PATH}"
kubectl apply -k "${PROFILE_PATH}"

echo "Waiting for rollout"
kubectl -n "${NAMESPACE}" rollout status deployment/spider-api --timeout=180s

echo ""
echo "Cluster is ready."
echo "To test locally, run:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/spider-api 8080:80"
echo "Then open:"
echo "  http://localhost:8080/healthz"
