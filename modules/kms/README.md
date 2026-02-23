# KMS Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

## Description

This module manages Google Cloud KMS (Key Management Service) resources in a consistent “CFF‐style”:
- Creates or imports KMS Key Rings  
- Creates or imports KMS Crypto Keys  
- Applies IAM policies on crypto keys via both “binding” and “member” resources  
- Merges data and resource key rings into a unified lookup  

## Features

- **Key ring lifecycle**: create new key rings or import existing ones via data sources  
- **Crypto key lifecycle**: create new keys, with rotation, destruction scheduling, and optional version templates  
- **IAM policy management**: authoritative bindings and individual members for crypto keys, with conditional support  
- **Unified lookup**: merges created and imported key rings for easier cross‐reference
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [data_kms_crypto_keys](variables.tf#L1) | Map of existing crypto keys to be imported. | <code title="map&#40;object&#40;&#123;&#10;  name     &#61; string&#10;  key_ring &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [data_kms_key_rings](variables.tf#L10) | Map of existing key rings to be imported. | <code title="map&#40;object&#40;&#123;&#10;  name     &#61; string&#10;  location &#61; string&#10;  project  &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [default_labels](variables.tf#L20) | Default labels to be applied to all resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L26) | Separator to use when joining prefix with resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [kms_crypto_key_iam_bindings](variables.tf#L32) | Map of IAM bindings for crypto keys. | <code title="map&#40;object&#40;&#123;&#10;  crypto_key_id &#61; string&#10;  role          &#61; string&#10;  memebers      &#61; list&#40;string&#41;&#10;  condition &#61; optional&#40;object&#40;&#123;&#10;    title       &#61; string&#10;    description &#61; string&#10;    expression  &#61; string&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [kms_crypto_key_iam_members](variables.tf#L47) | Map of IAM members for crypto keys. | <code title="map&#40;object&#40;&#123;&#10;  crypto_key_id &#61; string&#10;  role          &#61; string&#10;  member        &#61; string&#10;  condition &#61; optional&#40;object&#40;&#123;&#10;    title       &#61; string&#10;    description &#61; string&#10;    expression  &#61; string&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [kms_crypto_keys](variables.tf#L62) | Map of crypto keys to be created. | <code title="map&#40;object&#40;&#123;&#10;  name                          &#61; string&#10;  key_ring                      &#61; string&#10;  labels                        &#61; map&#40;string&#41;&#10;  purpose                       &#61; string&#10;  rotation_period               &#61; string&#10;  destroy_scheduled_duration    &#61; optional&#40;string&#41;&#10;  import_only                   &#61; optional&#40;bool&#41;&#10;  skip_initial_version_creation &#61; optional&#40;bool&#41;&#10;  version_template &#61; optional&#40;object&#40;&#123;&#10;    algorithm        &#61; string&#10;    protection_level &#61; string&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [kms_key_rings](variables.tf#L81) | Map of key rings to be created. | <code title="map&#40;object&#40;&#123;&#10;  name     &#61; string&#10;  location &#61; string&#10;  project  &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L91) | Prefix to be used for resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [crypto_keys](outputs.tf#L1) | Map of created crypto keys. |  |
| [iam_bindings](outputs.tf#L15) | Map of IAM bindings created. |  |
| [iam_members](outputs.tf#L27) | Map of IAM members created. |  |
| [imported_crypto_keys](outputs.tf#L39) | Map of imported crypto keys. |  |
| [imported_key_rings](outputs.tf#L50) | Map of imported key rings. |  |
| [key_rings](outputs.tf#L62) | Map of created key rings. |  |
<!-- END TFDOC -->
## Example Usage

```hcl
module "kms" {
  source             = "git::https://gitlab.com/your-org/terraform-modules.git//modules/gcp/security/kms"
  default_labels     = { team = "infra" }
  resource_prefix    = "prod"

  # Create both key rings and keys
  kms_key_rings = {
    ring1 = {
      name     = "app-ring"
      location = "us-central1"
      project  = "my-gcp-project"
    }
  }

  kms_crypto_keys = {
    key1 = {
      name                = "app-key"
      key_ring            = "ring1"
      labels              = { env = "prod" }
      purpose             = "ENCRYPT_DECRYPT"
      rotation_period     = "2592000s"
      skip_initial_version_creation = false
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }

  # Import existing key rings / keys
  data_kms_key_rings = {
    shared_ring = {
      name     = "shared-ring"
      location = "us-east1"
      project  = "shared-project"
    }
  }
  data_kms_crypto_keys = {
    shared_key = {
      name     = "shared-key"
      key_ring = "shared_ring"
    }
  }

  # Attach IAM policies
  kms_crypto_key_iam_bindings = {
    bind1 = {
      crypto_key_id = "key1"
      role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      memebers      = ["group:crypto-admins@example.com"]
    }
  }
  kms_crypto_key_iam_members = {
    member1 = {
      crypto_key_id = "key1"
      role          = "roles/cloudkms.viewer"
      member        = "user:auditor@example.com"
    }
  }
}
