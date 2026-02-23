# Spider

Project Spider is a modern, declarative Kubernetes cluster lifecycle and operations tool designed to surpass the capabilities of kops. It combines Cluster API (CAPI), GitOps workflows, Karpenter, and Terraform to provide robust multi‑cluster management with safe, staged upgrades and a standardised set of add‑ons.

## Goals

- **Declarative cluster lifecycle management via CAPI** – all clusters are represented as Kubernetes objects.
- **Git as the single source of truth** – clusters, add‑ons and configuration live in version control; no manual changes.
- **Safe, staged upgrades** – upgrade Kubernetes versions and machine infrastructure separately from add‑ons.
- **Standardised “cluster profiles”** – ensure consistency across development, staging and production clusters.
- **Separation of concerns**:
  - Terraform manages cloud primitives (VPCs, IAM roles, DNS, load balancers, etc.)
  - Cluster API manages the lifecycle of Kubernetes clusters
  - Argo CD manages add‑ons and applications via continuous reconciliation
- **Day‑2 operations baked in** – autoscaling (via Karpenter), policy enforcement (via Kyverno/Gatekeeper), observability, ingress controllers and data‑platform components come as part of the default profile.

## Repository layout

- `platform/terraform/` – Infrastructure code for cloud networking, IAM, DNS, and supporting services
- `platform/capi-management-cluster/` – Manifests for the management cluster running Cluster API controllers and Argo CD
- `clusters/` – Environment‑ and cluster‑specific CAPI objects and Argo bootstrap manifests
- `addons/` – Add‑on definitions grouped by functionality (base, security, observability, ingress, data platform)
- `apps/` – Tenant applications and environment‑specific overlays
- `pipelines/` – CI/CD definitions (e.g. GitHub Actions) to lint, validate and promote changes

## Getting started

1. **Bootstrap a management cluster** (which could be a small EKS cluster, kind cluster or other Kubernetes installation) and install Cluster API providers along with Argo CD.
2. **Define clusters** by creating a folder under `clusters/<env>/<cluster-name>` containing the Cluster API objects (e.g. Cluster, ControlPlane, MachineDeployment) and an Argo CD Application that bootstraps the add‑ons.
3. **Add or update add‑on charts** in the `addons/` directories, and reference them from your cluster profile. A cluster profile is an Argo CD ApplicationSet that includes the base add‑ons (CNI, CoreDNS, metrics‑server), security policies, observability stack, ingress controller, and optional data platform components.
4. **Define CI/CD pipelines** in the `pipelines/` directory (e.g. GitHub Actions) to run validation (YAML linting, Kustomize build, `terraform plan`), enforce policies, and promote changes across environments.
5. **Use pull requests** to manage changes to infrastructure, clusters and add‑ons. Argo CD will reconcile the desired state to the actual clusters automatically.
