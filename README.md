<p align="center">
  <h1 align="center">🏗️ gcp-infra-archtf</h1>
  <p align="center">
    <strong>Enterprise-Grade Terraform Modules for Google Cloud Platform</strong>
  </p>
  <p align="center">
    <em>Hardened by Default · Test-Driven · Identity-First · Governance-Ready</em>
  </p>
</p>

<p align="center">
  <a href="https://github.com/hilmanmustofaa/gcp-infra-archtf/actions/workflows/ci-e2e.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/hilmanmustofaa/gcp-infra-archtf/ci-e2e.yml?branch=main&label=CI%20%2F%20E2E&logo=github&style=flat-square" alt="CI Status">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Security-KMS%20%2B%20WIF%20%2B%20Shielded-4ade80?style=flat-square&logo=google-cloud&logoColor=white" alt="Security">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/IaC-Terraform%20%E2%89%A5%201.3-7b61ff?style=flat-square&logo=terraform&logoColor=white" alt="Terraform">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/FinOps-Label%20Enforced-f59e0b?style=flat-square&logo=google-analytics&logoColor=white" alt="FinOps">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Testing-.tftest.hcl-22d3ee?style=flat-square&logo=checkmarx&logoColor=white" alt="Tests">
  </a>
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square" alt="License">
  </a>
</p>

---

## Architectural Pillars

| Pillar                      | Description                                                                                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 🔒 **Hardened by Default**  | GKE clusters **require** Cloud KMS encryption and custom service accounts. Compute VMs enforce shielded instance configs. No fallback to default compute SA. |
| 🧪 **Test-Driven**          | Every module ships with `.tftest.hcl` plan-based tests. E2E scenarios validate security invariants (encryption, SA, labels) at plan time.                    |
| 🪪 **Identity-First (WIF)** | CI/CD uses **Workload Identity Federation** — no long-lived service account keys. GitHub Actions authenticate via OIDC tokens.                               |
| 📋 **Governance-Ready**     | All resources carry mandatory FinOps labels (`env`, `project`, `owner`). Validation blocks reject non-compliant inputs at `terraform plan`.                  |

---

## 🏛️ Enterprise-Grade E2E Blueprints

These blueprints demonstrate production-ready architectures by combining multiple modules into secure, governance-compliant end-to-end scenarios.

| Blueprint                                                           | Key Components           | Core Hardening                                                                |
| :------------------------------------------------------------------ | :----------------------- | :---------------------------------------------------------------------------- |
| [**GKE NodePools**](./examples/e2e-gke-with-nodepools)              | GKE + VPC + NodePools    | **KMS Secrets**, Custom Node SA, Master Authorized Networks, Spot VMs.        |
| [**Compute Web Stack**](./examples/e2e-compute-tls-lb-armor)        | MIG + LB + Cloud Armor   | **Global HTTPS LB**, Google-managed SSL, disk encryption, IP whitelisting.    |
| [**Secured Data Tier**](./examples/e2e-secured-data-tier)           | Cloud SQL + GCS + KMS    | **Dual-Key KMS**, Private DB (PSA), scoped SA permissions, encrypted buckets. |
| [**Organization Governance**](./examples/e2e-organization-baseline) | Folders + Projects + FWs | **Org Policies**, Centralized Log Sinks, Governance Tags, Hierarchical FWs.   |
| [**Serverless Modern App**](./examples/e2e-serverless-modern-app)   | Cloud Run + SQL + Secret | **VPC Access Connector**, Private SQL connectivity, Secret Manager injection. |

---

## Module Catalog — 30 Production Modules

### Compute

| Module                                                     | Description                                                                 |
| ---------------------------------------------------------- | --------------------------------------------------------------------------- |
| [`gke-cluster`](./modules/gke-cluster)                     | GKE Standard cluster with **mandatory KMS** + custom SA + Workload Identity |
| [`gke-autopilot-cluster`](./modules/gke-autopilot-cluster) | GKE Autopilot with managed control plane                                    |
| [`gke-nodepool`](./modules/gke-nodepool)                   | Node pool management with GPU/TPU support                                   |
| [`gke-hub`](./modules/gke-hub)                             | Fleet management and multi-cluster mesh                                     |
| [`compute-vm`](./modules/compute-vm)                       | VMs, instance templates, and resource policies with **mandatory custom SA** |
| [`compute-mig`](./modules/compute-mig)                     | Managed Instance Groups with autoscaling                                    |

### Networking

| Module                                                 | Description                                            |
| ------------------------------------------------------ | ------------------------------------------------------ |
| [`net-vpc`](./modules/net-vpc)                         | VPC networks, subnets, routes, and policy-based routes |
| [`net-vpc-firewall`](./modules/net-vpc-firewall)       | VPC firewall rules (ingress/egress)                    |
| [`net-vpc-peering`](./modules/net-vpc-peering)         | VPC peering with custom route exchange                 |
| [`net-cloudnat`](./modules/net-cloudnat)               | Cloud NAT gateway configuration                        |
| [`net-router`](./modules/net-router)                   | Cloud Router with BGP support                          |
| [`net-vpn`](./modules/net-vpn)                         | Classic and HA VPN tunnels                             |
| [`net-lb`](./modules/net-lb)                           | Load balancers (global, regional, internal, external)  |
| [`net-ncc`](./modules/net-ncc)                         | Network Connectivity Center (NCC) hubs and spokes      |
| [`net-firewall-policy`](./modules/net-firewall-policy) | Hierarchical and network firewall policies             |
| [`net-security-policy`](./modules/net-security-policy) | Cloud Armor security policies                          |
| [`net-address`](./modules/net-address)                 | Static IP address management                           |

### Storage & Database

| Module                                             | Description                                   |
| -------------------------------------------------- | --------------------------------------------- |
| [`gcs`](./modules/gcs)                             | Cloud Storage buckets with lifecycle policies |
| [`cloudsql-instance`](./modules/cloudsql-instance) | Cloud SQL instances (MySQL/PostgreSQL)        |
| [`firestore`](./modules/firestore)                 | Firestore database and indexes                |

### Security & IAM

| Module                                                   | Description                                |
| -------------------------------------------------------- | ------------------------------------------ |
| [`iam-service-accounts`](./modules/iam-service-accounts) | Service account creation with IAM bindings |
| [`kms`](./modules/kms)                                   | Cloud KMS key rings and crypto keys        |
| [`organization`](./modules/organization)                 | Org policies, tags, logging, and IAM       |

### Platform Services

| Module                                                 | Description                                    |
| ------------------------------------------------------ | ---------------------------------------------- |
| [`artifact-registry`](./modules/artifact-registry)     | Artifact Registry repositories                 |
| [`cloud-run`](./modules/cloud-run)                     | Cloud Run services (v1)                        |
| [`cloud-run-v2`](./modules/cloud-run-v2)               | Cloud Run services (v2) with traffic splitting |
| [`cdn`](./modules/cdn)                                 | Cloud CDN with backend bucket                  |
| [`dns`](./modules/dns)                                 | Cloud DNS zones and record sets                |
| [`dns-response-policy`](./modules/dns-response-policy) | DNS Response Policies                          |
| [`ssl-certificate`](./modules/ssl-certificate)         | Managed SSL certificates                       |

---

## Quick Start

```hcl
module "gke" {
  source = "github.com/hilmanmustofaa/gcp-infra-archtf//modules/gke-cluster"

  name       = "prod-cluster"
  project_id = "my-project"
  location   = "asia-southeast2"

  network    = "projects/my-project/global/networks/prod-vpc"
  subnetwork = "projects/my-project/regions/asia-southeast2/subnetworks/gke-subnet"

  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"

  # 🔒 Mandatory: KMS encryption
  database_encryption = {
    state    = "ENCRYPTED"
    key_name = "projects/my-project/locations/asia-southeast2/keyRings/gke/cryptoKeys/secrets"
  }

  # 🔒 Mandatory: Custom service account
  node_service_account = "gke-nodes@my-project.iam.gserviceaccount.com"

  # 📋 Mandatory: FinOps labels
  default_labels = {
    env     = "production"
    project = "my-project"
    owner   = "platform-team"
  }
}
```

---

## How to Use

### Prerequisites

| Tool                                                  | Version    |
| ----------------------------------------------------- | ---------- |
| [Terraform](https://www.terraform.io/)                | `>= 1.3.0` |
| [Task](https://taskfile.dev/)                         | `3.x`      |
| [TFLint](https://github.com/terraform-linters/tflint) | `latest`   |
| [tfsec](https://aquasecurity.github.io/tfsec/)        | `latest`   |
| Python                                                | `3.9+`     |

### Task Commands

```bash
# Run all checks (fmt + validate + lint + security + test)
task check

# Individual tasks
task fmt            # Check Terraform formatting
task validate       # Validate all modules
task lint           # Run TFLint
task security       # Run tfsec with SARIF output
task test           # Run all .tftest.hcl tests
task test:changed   # Run tests on changed modules only
task docs           # Generate READMEs via tfdoc.py
task clean          # Clean generated files
```

### CI/CD Pipeline

This repo ships with a **Dynamic Matrix** GitHub Actions workflow (`.github/workflows/ci-e2e.yml`) that:

1. **🔍 Discovers** changed modules on PR (all modules on push to `main`)
2. **✅ Validates** each module in parallel (init → validate → fmt → tflint)
3. **🔒 Scans** each module with tfsec and uploads SARIF to GitHub Security tab
4. **🧪 Tests** each module's `.tftest.hcl` with optional WIF authentication
5. **🧹 Cleans up** via `always()` hook — ensures `terraform destroy` runs even on failure

#### Setting up WIF

Set these GitHub repository variables for Workload Identity Federation:

| Variable              | Example                                                                       |
| --------------------- | ----------------------------------------------------------------------------- |
| `WIF_PROVIDER`        | `projects/123/locations/global/workloadIdentityPools/github/providers/github` |
| `WIF_SERVICE_ACCOUNT` | `github-ci@my-project.iam.gserviceaccount.com`                                |

---

## FinOps Label Standard

All modules enforce these mandatory labels via Terraform `validation` blocks:

| Label     | Purpose                    | Example                          |
| --------- | -------------------------- | -------------------------------- |
| `env`     | Environment name           | `production`, `staging`, `dev`   |
| `project` | Business project/product   | `platform-core`, `data-pipeline` |
| `owner`   | Responsible team or person | `platform-team`, `sre`           |

Additional automatic labels are set per module:

| Label            | Purpose                                     |
| ---------------- | ------------------------------------------- |
| `gcp_asset_type` | Cloud Asset Inventory type                  |
| `gcp_service`    | GCP service API                             |
| `tf_module`      | Terraform module name                       |
| `tf_layer`       | Architecture layer (compute, network, etc.) |

---

## Documentation

Sub-module READMEs are auto-generated using [`tools/tfdoc.py`](./tools/tfdoc.py). Run:

```bash
task docs
```

This parses `variables.tf`, `outputs.tf`, and `main.tf` to generate Markdown tables with types, defaults, and descriptions.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines.

---

## License

```
Copyright 2026 ToyLabs

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
```

See [LICENSE](./LICENSE) for the full text.
