# GCP Landing Zone & Organization Setup Guide

This document outlines the professional workflow for establishing a new Google Cloud Organization and deploying a production-ready Landing Zone using the `gcp-infra-archtf` module suite.

## 🏛️ Architecture Overview

We follow the **Hub-and-Spoke** topology with a **Shared VPC** architecture. This ensures centralized control over networking and security while allowing decentralized workload management.

### The 5 Architectural Pillars

1.  **Identity:** Managed via Cloud Identity/Google Workspace with mandatory MFA.
2.  **Hierarchy:** Logic-based Folder structure for environment isolation.
3.  **Connectivity:** Shared VPC (Hub) for transit and Spoke VPCs for isolated workloads.
4.  **Governance:** "Guardrails" enforced via Organization Policies and Hierarchical Firewalls.
5.  **Observability:** Centralized Audit Logging (WORM) and cross-project monitoring.

---

## 🛠️ Phase 1: Manual Bootstrap (The "Seed" Phase)

Before automation can take over, the "Seed" infrastructure must be established manually via the GCP Console or `gcloud` CLI.

### 1. Account & Billing

- Verify your domain in **Cloud Identity**.
- Set up a **Billing Account** and ensure you have `Billing Account Administrator` permissions.

### 2. Seed Project Setup

Create a dedicated project for automation:

- **Project Name:** `prj-b-seed-automation`
- **Purpose:** Host the Terraform state and the deployment Service Account.

### 3. Terraform State Backend

- Create a GCS Bucket in the Seed Project: `gs://<prefix>-terraform-state`.
- **CRITICAL:** Enable **Object Versioning** on this bucket.

### 4. Deployment Service Account (The Master)

- Create a Service Account: `sa-tf-bootstrap@prj-b-seed-automation.iam.gserviceaccount.com`.
- Assign the following **Organization-level** roles to this SA:
  - `roles/resourcemanager.organizationAdmin`
  - `roles/resourcemanager.folderAdmin`
  - `roles/resourcemanager.projectCreator`
  - `roles/billing.user` (at the Billing Account level)
  - `roles/compute.orgSecurityPolicyAdmin` (for Hierarchical Firewalls)

---

## 🚀 Phase 2: Automated Deployment (Terraform)

Once the Seed SA is ready, use the `gcp-infra-archtf` modules to build the rest.

### Step A: Organization Baseline

Run the `organization` module to establish the foundation:

- **Folder Hierarchy:** `Common`, `Management`, `Production`, `Development`.
- **Org Policies:** Enable mandatory security constraints (Disable external IPs, enforce CMEK).
- **Audit Logging:** Setup Org-wide sinks to send all audit logs to a dedicated `Audit` project.

### Step B: Core Networking (Shared VPC)

Run the `net-vpc`, `net-router`, and `net-firewall-policy` modules:

- **Hub VPC:** Create the Shared VPC project in the `Common` folder.
- **Firewall Policies:** Deploy the baseline hierarchical firewall policies.
- **Hybrid Link:** Setup HA VPN or Interconnect for on-premise connectivity.

### Step C: Workload Provisioning

Projects and resources are now deployed within the established hierarchy:

- Use `net-vpc` to associate Spoke projects with the Shared VPC.
- Use `gke-cluster` or `compute-vm` for specific application runtimes.

---

## 🛡️ Ongoing Governance & Maintenance

- **Dependabot:** Keep module dependencies updated automatically.
- **CI/CD:** Use the provided `.github/workflows/ci-e2e.yml` to validate changes before merging to `main`.
- **Policy Monitoring:** Review Org Policy violations via the Asset Inventory dashboard.

---

> [!IMPORTANT]
> Always use Customer-Managed Encryption Keys (CMEK) for sensitive data storage (GCS, SQL, GKE Secrets).
