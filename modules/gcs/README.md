# Google Cloud Storage (GCS) Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Module Labels & FinOps](#module-labels-finops)
- [Testing](#testing)
- [Version Compatibility](#version-compatibility)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
  - [Basic Example](#basic-example)
  - [Objects Example](#objects-example)
<!-- END TOC -->

## Description

This Terraform module provisions and manages **Google Cloud Storage (GCS)** buckets and objects through a unified interface.
It supports creating multiple buckets with flexible configurations—versioning, lifecycle rules, retention policies, access logging, static website hosting, and custom placement—and optionally uploads objects with metadata, cache control, content type, and encryption settings.

---

## Features

✅ **Multi-bucket provisioning**
Create and configure multiple GCS buckets with per-bucket settings and labels.

✅ **Lifecycle & retention**
Automate object deletion or archiving, and enforce compliance retention policies with optional locks.

✅ **Uniform bucket-level access**
Enable IAM-only access and consistent access control behavior.

✅ **Access logging**
Send bucket access logs to a specified logging bucket.

✅ **Static website hosting**
Serve static assets via built-in website configuration.

✅ **Custom placement configuration**
Specify multi-region data placement locations.

✅ **Object uploads**
Upload files or inline content with optional metadata and customer-supplied encryption keys.

✅ **FinOps-ready labels**
Automatically injects standardized module labels for cost allocation and resource ownership tracking.

---

## Module Labels & FinOps

By default, every bucket includes the following FinOps labels:

```hcl
{
  gcp_asset_type = "storage.googleapis.com/Bucket"
  gcp_service    = "storage.googleapis.com"
  tf_module      = "gcs-bucket"
  tf_layer       = "storage"
  tf_resource    = "bucket"
}
```

These are merged with user-defined `default_labels` and any per-bucket `labels` for consistent cost reporting.

You can export these labels for reporting via `output.finops_labels`.

---

## Testing

Run all built-in tests (Terraform ≥ 1.9):

```bash
terraform -chdir=modules/gcs test -no-color
```

Available test scenarios:

* `basic_test` — validates FinOps label merge and name prefix logic
* `objects_test` — verifies object creation mapping and output consistency

Each test uses Terraform ≥ 1.10.2 syntax (`variables {}` blocks).

---

## Version Compatibility

| Component             | Version   | Notes                                              |
| --------------------- | --------- | -------------------------------------------------- |
| **Terraform**         | ≥ 1.10.2  | Uses new test block syntax                         |
| **Provider – Google** | v6.50.0 + | Required for bucket retention & lifecycle features |
| **tfdocs**            | v0.16 +   | Used for auto-generating this documentation        |

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L35) | The ID of the project where the buckets will be created. | <code>string</code> | ✓ |  |
| [default_labels](variables.tf#L1) | Default labels to be applied to all buckets. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L7) | Separator used when joining prefix with resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [objects](variables.tf#L13) | Map of objects to be created in the buckets. | <code title="map&#40;object&#40;&#123;&#10;  bucket              &#61; string&#10;  name                &#61; string&#10;  metadata            &#61; optional&#40;map&#40;string&#41;&#41;&#10;  content             &#61; optional&#40;string&#41;&#10;  source              &#61; optional&#40;string&#41;&#10;  cache_control       &#61; optional&#40;string&#41;&#10;  content_disposition &#61; optional&#40;string&#41;&#10;  content_encoding    &#61; optional&#40;string&#41;&#10;  content_language    &#61; optional&#40;string&#41;&#10;  content_type        &#61; optional&#40;string&#41;&#10;  storage_class       &#61; optional&#40;string&#41;&#10;  customer_encryption &#61; optional&#40;object&#40;&#123;&#10;    encryption_algorithm &#61; string&#10;    encryption_key       &#61; string&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L40) | Optional prefix for resource names. | <code>string</code> |  | <code>null</code> |
| [storage_buckets](variables.tf#L46) | Map of storage buckets to create with their configurations. | <code title="map&#40;object&#40;&#123;&#10;  name                        &#61; string&#10;  location                    &#61; string&#10;  labels                      &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  force_destroy               &#61; optional&#40;bool, false&#41;&#10;  uniform_bucket_level_access &#61; optional&#40;bool, true&#41;&#10;  public_access_prevention    &#61; optional&#40;string, &#34;inherited&#34;&#41;&#10;  storage_class               &#61; optional&#40;string&#41;&#10;&#10;&#10;  versioning &#61; optional&#40;object&#40;&#123;&#10;    enabled &#61; optional&#40;bool, false&#41;&#10;  &#125;&#41;, &#123;&#125;&#41;&#10;&#10;&#10;  autoclass &#61; optional&#40;bool&#41;&#10;&#10;&#10;  encryption &#61; optional&#40;object&#40;&#123;&#10;    kms_key_name &#61; string&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  lifecycle_rules &#61; optional&#40;map&#40;object&#40;&#123;&#10;    action &#61; object&#40;&#123;&#10;      type          &#61; string&#10;      storage_class &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#10;    condition &#61; object&#40;&#123;&#10;      age                        &#61; optional&#40;number&#41;&#10;      created_before             &#61; optional&#40;string&#41;&#10;      custom_time_before         &#61; optional&#40;string&#41;&#10;      days_since_custom_time     &#61; optional&#40;number&#41;&#10;      days_since_noncurrent_time &#61; optional&#40;number&#41;&#10;      matches_prefix             &#61; optional&#40;list&#40;string&#41;&#41;&#10;      matches_storage_class      &#61; optional&#40;list&#40;string&#41;&#41;&#10;      matches_suffix             &#61; optional&#40;list&#40;string&#41;&#41;&#10;      noncurrent_time_before     &#61; optional&#40;string&#41;&#10;      num_newer_versions         &#61; optional&#40;number&#41;&#10;      with_state                 &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;&#41;&#10;&#10;&#10;  retention_policy &#61; optional&#40;object&#40;&#123;&#10;    is_locked        &#61; optional&#40;bool, false&#41;&#10;    retention_period &#61; optional&#40;number&#41;&#10;  &#125;&#41;, &#123;&#125;&#41;&#10;&#10;&#10;  logging &#61; optional&#40;object&#40;&#123;&#10;    log_bucket        &#61; optional&#40;string&#41;&#10;    log_object_prefix &#61; optional&#40;string&#41;&#10;  &#125;&#41;, &#123;&#125;&#41;&#10;&#10;&#10;  website &#61; optional&#40;object&#40;&#123;&#10;    main_page_suffix &#61; optional&#40;string&#41;&#10;    not_found_page   &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  custom_placement_config &#61; optional&#40;list&#40;string&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [buckets](outputs.tf#L1) | Map of created bucket resources. |  |
| [finops_labels](outputs.tf#L9) | FinOps label package for this module (module + default_labels var), to be merged with workspace-level defaults. |  |
| [names](outputs.tf#L14) | Map of bucket names. |  |
| [objects](outputs.tf#L22) | Map of created objects. |  |
| [urls](outputs.tf#L34) | Map of bucket URLs. |  |
<!-- END TFDOC -->
---

## Example Usage

### Basic Example

```hcl
module "gcs" {
  source          = "git::https://gitlab-ci-token:__GITLAB_TOKEN__@gitlab.ss-wlabid.net/devsecops/terraform-modules-gcp.git//modules/storage/gcs?ref=v1.5.0"
  project_id      = "my-gcp-project"
  resource_prefix = "app"

  default_labels = {
    environment = "prod"
    team        = "platform"
  }

  storage_buckets = {
    logs = {
      name     = "app-logs"
      location = "US"
      labels   = { purpose = "audit" }

      versioning = { enabled = true }

      lifecycle_rules = {
        cleanup = {
          action    = { type = "Delete" }
          condition = { age = 30 }
        }
      }

      retention_policy = {
        is_locked        = false
        retention_period = 86400
      }

      logging = {
        log_bucket        = "app-logs"
        log_object_prefix = "logs/"
      }

      website = {
        main_page_suffix = "index.html"
        not_found_page   = "404.html"
      }
    }
  }

  objects = {}
}
```

### Objects Example

```hcl
module "gcs_objects" {
  source     = "git::https://gitlab-ci-token:__GITLAB_TOKEN__@gitlab.ss-wlabid.net/devsecops/terraform-modules-gcp.git//modules/storage/gcs?ref=v1.5.0"
  project_id = "my-gcp-project"

  storage_buckets = {
    main = {
      name     = "demo-objects-bucket"
      location = "US"
    }
  }

  objects = {
    config = {
      bucket        = "main"
      name          = "config.json"
      content       = jsonencode({ foo = "bar" })
      content_type  = "application/json"
      cache_control = "no-cache"
    }
  }
}
```