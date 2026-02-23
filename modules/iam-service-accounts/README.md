# IAM Service Accounts Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [FinOps Label Integration](#finops-label-integration)
- [Version Compatibility](#version-compatibility)
- [Testing](#testing)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
  - [🧱 Basic Example](#-basic-example)
  - [🔐 With IAM Bindings](#-with-iam-bindings)
  - [🧩 Existing Service Account Example](#-existing-service-account-example)
<!-- END TOC -->

## Description

This module provisions and manages **Google Cloud IAM Service Accounts**, with optional key generation, granular IAM bindings on the service account itself, project-level IAM roles, and Google Cloud Storage bucket IAM bindings.  
It supports both creating new service accounts or referencing existing ones, and applying both **authoritative** and **additive** IAM patterns.

---

## Features

✅ **Service account creation or lookup** – create a new SA or reference an existing one by `account_id`.  
✅ **Optional key generation** for the service account.  
✅ **Authoritative IAM bindings** on the service account (replace existing bindings).  
✅ **Additive IAM bindings** on the service account (append to existing bindings).  
✅ **Project-level IAM roles** for the service account.  
✅ **Google Storage bucket IAM roles** for the service account.  
✅ **Flexible conditional IAM policy** support.  
✅ **FinOps label output** for consistent cost allocation across modules.

---

## FinOps Label Integration

Each module automatically injects FinOps-standard labels:

```hcl
{
  gcp_asset_type = "iam.googleapis.com/ServiceAccount"
  gcp_service    = "iam.googleapis.com"
  tf_module      = "iam-service-account"
  tf_layer       = "identity"
  tf_resource    = "service_account"
}
````

You can add more labels via the `labels` variable (e.g., `environment`, `team`, `cost_center`)
and merge them later at the workspace or root module level.

---

## Version Compatibility

| Component             | Version   | Notes                                               |
| --------------------- | --------- | --------------------------------------------------- |
| **Terraform**         | ≥ 1.10.2  | Required for `terraform test` block syntax          |
| **Provider – Google** | v6.50.0 + | Required for strict IAM `service_account_id` format |
| **tfdocs**            | v0.16 +   | Used for auto-generating documentation              |

---

## Testing

Run module tests locally:

```bash
terraform -chdir=modules/iam-service-accounts test -no-color
```

Available test scenarios:

* `basic_test` — create minimal service account with no bindings.
* `plan_with_bindings` — test full IAM binding structure (authoritative + additive + project/bucket-level).

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [account_id](variables.tf#L1) | The account id of the service account. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L87) | Project id where service account will be created. | <code>string</code> | ✓ |  |
| [description](variables.tf#L6) | Description of the service account. | <code>string</code> |  | <code>null</code> |
| [disabled](variables.tf#L12) | Whether the service account is disabled. | <code>bool</code> |  | <code>false</code> |
| [display_name](variables.tf#L18) | Display name of the service account. | <code>string</code> |  | <code>&#34;Terraform-managed service account.&#34;</code> |
| [generate_key](variables.tf#L24) | Whether to generate a service account key. | <code>bool</code> |  | <code>false</code> |
| [iam_bindings](variables.tf#L30) | Authoritative IAM bindings in {KEY => {role = ROLE, members = [], condition = {}}}. Keys are arbitrary. | <code title="map&#40;object&#40;&#123;&#10;  members &#61; list&#40;string&#41;&#10;  role    &#61; string&#10;  condition &#61; optional&#40;object&#40;&#123;&#10;    expression  &#61; string&#10;    title       &#61; string&#10;    description &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_bindings_additive](variables.tf#L45) | Individual additive IAM bindings. Keys are arbitrary. | <code title="map&#40;object&#40;&#123;&#10;  member &#61; string&#10;  role   &#61; string&#10;  condition &#61; optional&#40;object&#40;&#123;&#10;    expression  &#61; string&#10;    title       &#61; string&#10;    description &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L60) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [labels](variables.tf#L66) | Additional FinOps labels to merge with the module's default labels (gcp_asset_type, gcp_service, tf_module, tf_layer, tf_resource). | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [project_iam_bindings](variables.tf#L78) | Project-level IAM bindings for the service account. Keyed by arbitrary id. | <code title="map&#40;object&#40;&#123;&#10;  project &#61; optional&#40;string&#41;&#10;  role    &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L72) | Prefix applied to service account names. | <code>string</code> |  | <code>null</code> |
| [service_account_create](variables.tf#L92) | Create new service account. When set to false, uses a data source to reference an existing service account. | <code>bool</code> |  | <code>true</code> |
| [storage_bucket_iam_bindings](variables.tf#L98) | Storage bucket IAM bindings for the service account. Keyed by arbitrary id. | <code title="map&#40;object&#40;&#123;&#10;  bucket &#61; string&#10;  role   &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [email](outputs.tf#L1) | Service account email. |  |
| [finops_labels](outputs.tf#L11) | FinOps label package for this module (module + labels var), to be merged with workspace-level defaults. |  |
| [iam_email](outputs.tf#L16) | IAM-format service account email. |  |
| [id](outputs.tf#L26) | Fully qualified service account id. |  |
| [key](outputs.tf#L36) | Service account key, if one was created. | ✓ |
| [name](outputs.tf#L45) | Service account name. |  |
| [service_account](outputs.tf#L55) | Service account resource. |  |
<!-- END TFDOC -->
---

## Example Usage

### 🧱 Basic Example

[`examples/basic`](examples/basic/main.tf)

```hcl
module "service_account_basic" {
  source = "./modules/iam-service-accounts"

  project_id = "my-project"
  account_id = "app-basic-sa"

  display_name = "Basic application service account."
  description  = "Service account used by a basic application."
  disabled     = false

  service_account_create = true
  generate_key           = false

  labels = {
    environment = "dev"
    team        = "platform"
  }
}
```

### 🔐 With IAM Bindings

[`examples/with-project-and-bucket-iam`](examples/with-project-and-bucket-iam/main.tf)

```hcl
module "service_account_full_iam" {
  source = "./modules/iam-service-accounts"

  project_id = "my-project"
  account_id = "app-full-iam-sa"

  display_name = "Service account with project and bucket IAM."
  description  = "Full example with IAM bindings at multiple levels."

  iam_bindings = {
    token-creator = {
      role    = "roles/iam.serviceAccountTokenCreator"
      members = ["group:devs@example.com"]
    }
  }

  project_iam_bindings = {
    viewer = {
      role = "roles/viewer"
    }
  }

  storage_bucket_iam_bindings = {
    logs-bucket = {
      bucket = "my-logs-bucket"
      role   = "roles/storage.objectCreator"
    }
  }

  labels = {
    environment  = "prod"
    cost_center  = "cc-1001"
    owner_team   = "core-platform"
  }
}
```

---

### 🧩 Existing Service Account Example

[`examples/existing-service-account`](examples/existing-service-account/main.tf)

```hcl
module "existing_service_account" {
  source = "./modules/iam-service-accounts"

  project_id = "my-project"
  account_id = "existing-app-sa"

  service_account_create = false
  generate_key           = false

  iam_bindings = {
    sa-user = {
      role    = "roles/iam.serviceAccountUser"
      members = ["group:external@example.com"]
    }
  }

  labels = {
    environment = "prod"
    owner       = "external"
  }
}
```
