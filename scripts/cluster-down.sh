#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-spider-dev}"

if ! command -v kind >/dev/null 2>&1; then
  echo "Required command not found: kind" >&2
  exit 1
fi

kind delete cluster --name "${CLUSTER_NAME}"
