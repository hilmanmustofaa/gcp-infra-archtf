# Artifact Registry Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Module Labels & Naming](#module-labels-naming)
- [Testing](#testing)
- [Version Compatibility](#version-compatibility)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

## Description

This Terraform module provisions a **Google Artifact Registry** repository with full support for:

* multiple package formats (`docker`, `maven`, `npm`, `python`, `apt`, `yum`, `generic`)
* repository modes (`standard`, `remote`, `virtual`)
* cleanup policies and retention management
* CMEK encryption
* upstream proxy configuration
* workspace-ready FinOps labelling
* and testable module compatibility (Terraform ≥ 1.9+)

---

## Features

✅ **Multi-format support**
Supports Docker, Maven, npm, Python, Yum, Apt, or Generic repositories.

✅ **Repository modes**

* **STANDARD** – host your own packages
* **REMOTE** – proxy and cache upstream registries (Docker Hub, Maven Central, etc.)
* **VIRTUAL** – aggregate multiple repositories under one endpoint

✅ **Cleanup policies**
Define auto-cleanup rules by:

* age (`older_than`, `newer_than`)
* tag state (`UNTAGGED`, `TAGGED`)
* name prefixes
* “keep N most recent versions” semantics

✅ **CMEK encryption**
Optional `encryption_key` parameter allows at-rest encryption with a customer-managed key.

✅ **Upstream configuration**
Proxy upstream repositories with:

* `public_repository`
* `custom_repository`
* `upstream_credentials`

✅ **Input validation**
Built-in validation ensures format/mode consistency and RFC-1035-compliant repository names.

✅ **FinOps-ready labelling**
Each repository is auto-tagged with:

```hcl
{
  service = "artifactregistry.googleapis.com"
  module  = "artifact_registry"
}
```

These merge automatically with user-defined `var.labels` for consistent cost reporting.

✅ **Module testing support**
All test cases under `tests/*.tftest.hcl` follow Terraform ≥ 1.9 syntax with `variables {}` blocks.

---

## Module Labels & Naming

By default, the module attaches:

```hcl
{
  service = "artifactregistry.googleapis.com"
  module  = "artifact_registry"
}
```

These merge automatically with `var.labels`.
Repository names are validated against the Google Artifact Registry naming convention (`^[a-z][a-z0-9\-]+[a-z0-9]$`).

---

## Testing

Run all built-in tests (Terraform ≥ 1.9):

```bash
terraform -chdir=modules/artifact-registry test -no-color
```

Available test scenarios:

* `plan_basic_docker_standard`
* `plan_docker_without_immutable`
* `plan_maven_with_policies`
* `plan_invalid_repository_id`

Each test runs a temporary plan and validates expected attributes.

---

## Version Compatibility

| Component                  | Version                     | Notes                                                   |
| -------------------------- | --------------------------- | ------------------------------------------------------- |
| **Terraform**              | ≥ 1.9  (verified on 1.10.2) | Uses new `variables {}` test syntax                     |
| **Provider – Google**      | v6.50.0 +                   | Required for Artifact Registry API and cleanup policies |
| **Provider – Google Beta** | v6.50.0 +                   | Needed for certain Artifact Registry features           |
| **tfdocs**                 | v0.16 +                     | Used for automated documentation generation             |

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [cleanup_policies](variables.tf#L1) | Cleanup policies for this repository (DELETE/KEEP rules based on tag state, age and most recent versions). | <code title="map&#40;object&#40;&#123;&#10;  action &#61; string &#35; &#34;KEEP&#34; or &#34;DELETE&#34;.&#10;&#10;&#10;  condition &#61; optional&#40;object&#40;&#123;&#10;    tag_state             &#61; optional&#40;string&#41; &#35; &#34;TAGGED&#34;, &#34;UNTAGGED&#34;, &#34;ANY&#34;.&#10;    tag_prefixes          &#61; optional&#40;list&#40;string&#41;&#41;&#10;    version_name_prefixes &#61; optional&#40;list&#40;string&#41;&#41;&#10;    package_name_prefixes &#61; optional&#40;list&#40;string&#41;&#41;&#10;    older_than            &#61; optional&#40;string&#41; &#35; e.g. &#92;&#34;30d&#92;&#34;.&#10;    newer_than            &#61; optional&#40;string&#41; &#35; e.g. &#92;&#34;7d&#92;&#34;.&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  most_recent_versions &#61; optional&#40;object&#40;&#123;&#10;    package_name_prefixes &#61; optional&#40;list&#40;string&#41;&#41;&#10;    keep_count            &#61; number&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;&#10;&#10;&#10;default &#61; &#123;&#125;">map&#40;object&#40;&#123;&#8230;default &#61; &#123;&#125;</code> | ✓ |  |
| [format](variables.tf#L42) | The format of packages stored in the repository. Must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM. | <code>string</code> | ✓ |  |
| [location](variables.tf#L67) | Location (region or multi-region) of the Artifact Registry repository (for example: asia-southeast2). | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L109) | The project ID where the Artifact Registry repository will be created. | <code>string</code> | ✓ |  |
| [repository_id](variables.tf#L125) | The repository ID (last segment of the repository name). | <code>string</code> | ✓ |  |
| [cleanup_policy_dry_run](variables.tf#L24) | If true, cleanup policies are evaluated but artifacts are not actually deleted (recommended to keep true first for validation, then set to false once you are confident with the policies). | <code>bool</code> |  | <code>true</code> |
| [description](variables.tf#L30) | Optional description for the repository. | <code>string</code> |  | <code>null</code> |
| [docker_immutable_tags](variables.tf#L36) | Whether to enable immutable tags for Docker repositories (if null, docker_config is omitted; if set, immutable_tags is applied and tagged artifacts cannot be deleted by cleanup policies). | <code>bool</code> |  | <code>null</code> |
| [join_separator](variables.tf#L103) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [kms_key_name](variables.tf#L55) | Optional CMEK key for encrypting repository contents (projects/.../locations/.../keyRings/.../cryptoKeys/...). | <code>string</code> |  | <code>null</code> |
| [labels](variables.tf#L61) | Additional labels to merge with the module's default FinOps labels (gcp_asset_type, gcp_service, tf_module, tf_layer, tf_resource) and any env/product/cost_center labels you provide. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [maven_allow_snapshot_overwrites](variables.tf#L77) | Whether to allow Maven snapshot overwrites (MAVEN format only). | <code>bool</code> |  | <code>null</code> |
| [maven_version_policy](variables.tf#L83) | Maven version policy (MAVEN format only). Must be one of: VERSION_POLICY_UNSPECIFIED, RELEASE, SNAPSHOT. | <code>string</code> |  | <code>null</code> |
| [mode](variables.tf#L89) | Repository mode. Must be one of: STANDARD_REPOSITORY (standard local repository), VIRTUAL_REPOSITORY (virtual repository aggregating upstream repositories), REMOTE_REPOSITORY (remote cache backed by an upstream repository). | <code>string</code> |  | <code>&#34;STANDARD_REPOSITORY&#34;</code> |
| [resource_prefix](variables.tf#L119) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [finops_labels](outputs.tf#L1) | FinOps label package for this module (module + labels var), to be merged with workspace-level defaults. |  |
| [format](outputs.tf#L6) | The repository format. |  |
| [labels](outputs.tf#L11) | Effective labels applied to the repository. |  |
| [location](outputs.tf#L16) | Repository location (region or multi-region). |  |
| [name](outputs.tf#L21) | Full resource name of the repository (projects/PROJECT/locations/LOC/repositories/REPO_ID). |  |
| [project_id](outputs.tf#L26) | Project ID where the repository is created. |  |
| [repository_id](outputs.tf#L31) | The repository ID (last segment of the Artifact Registry repository name). |  |
| [repository_url](outputs.tf#L36) | Convenience URL/host form (for example: asia-southeast2-docker.pkg.dev/my-project/my-repo). |  |
<!-- END TFDOC -->
---

## Example Usage

```hcl
module "artifact_registry" {
  source      = "./modules/artifact-registry"
  project_id  = "my-project"
  location    = "us-central1"
  name        = "my-repo"
  description = "Multi-format registry for Docker and Maven"

  format = {
    docker = {
      standard = { immutable_tags = true }
    }
    maven   = null
    npm     = null
    python  = null
    apt     = null
    yum     = null
    generic = null
  }

  labels = {
    environment = "prod"
    team        = "platform"
  }

  encryption_key = "projects/my-project/locations/us/keyRings/my-ring/cryptoKeys/my-key"

  cleanup_policies = {
    auto-delete-old = {
      action    = "DELETE"
      condition = {
        older_than   = "30d"
        tag_prefixes = ["release-"]
      }
    }
    keep-5-latest = {
      action                = "KEEP"
      most_recent_versions = {
        package_name_prefixes = ["app-"]
        keep_count            = 5
      }
    }
  }
}
```

