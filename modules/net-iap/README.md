# Identity-Aware Proxy (IAP) Module

<!-- BEGIN TOC -->
- [Description](#description)
- [⚠️ IAP OAuth brand deprecation](#-iap-oauth-brand-deprecation)
- [Features](#features)
- [Security & Compliance Notes](#security-compliance-notes)
- [Example Usage](#example-usage)
- [Testing](#testing)
- [Requirements](#requirements)
- [Variables](#variables)
- [Outputs](#outputs)
<!-- END TOC -->

## Description

This module manages [Identity-Aware Proxy (IAP)](https://cloud.google.com/iap) access in three forms from a single interface:

1. **IAP tunnel instance IAM** — grant SSH/RDP access to VMs through IAP (no public IPs, no bastion exposure).
2. **IAP web backend service IAM** — protect Cloud Run / GKE / MIG workloads sitting behind an external HTTPS load balancer.
3. **IAP OAuth brand & client** — the project-level consent screen (singleton), created on an opt-in basis only.

IAP is mandatory for government engagements (every app fronted by IAP) and common for internal banking tooling.

> **This module has no labelable resources** — IAP IAM bindings and the OAuth brand do not accept resource labels — so it intentionally does **not** expose a `default_labels` variable. FinOps labelling is applied on the underlying compute / load-balancer / Cloud Run resources by their own modules.

---

## ⚠️ IAP OAuth brand deprecation

Google has deprecated the IAP OAuth Admin API. As of **July 2025** the `google_iap_brand` and `google_iap_client` resources no longer function for new brands. Accordingly:

- `create_brand` defaults to **`false`** and should stay that way for new projects.
- Manage the OAuth consent brand once per project via the Cloud Console / `gcloud`, then reference it.
- The brand/client resources remain in the module only for legacy import/compatibility.

The **tunnel** and **web backend** IAM bindings are fully supported and are the primary purpose of this module.

---

## Features

✅ **IAP tunnel IAM** — authoritative (`tunnel_instance_bindings`) and additive (`tunnel_instance_members`) bindings per instance, defaulting to `roles/iap.tunnelResourceAccessor`.

✅ **IAP web backend IAM** — authoritative (`web_backend_bindings`) and additive (`web_backend_members`) bindings per backend service, defaulting to `roles/iap.httpsResourceAccessor`.

✅ **Idempotent brand handling** — `create_brand` / `create_client` are `count`-guarded so the module can be called repeatedly against the same project without colliding on the singleton brand.

✅ **Cross-variable validation** — `create_brand` requires `brand`; `create_client` requires both `create_brand` and `oauth_client`.

---

## Security & Compliance Notes

- **Zero-trust VM access (govt + banking):** use `tunnel_instance_bindings` instead of public IPs / open SSH. Combine with firewall rules allowing only the IAP range (`35.235.240.0/20`).
- **Least privilege:** bind specific groups/service accounts, not `allUsers`/`allAuthenticatedUsers`.
- **Break-glass:** model emergency access as an additive `tunnel_instance_members` entry that can be removed independently of the authoritative binding.

---

## Example Usage

```hcl
module "iap" {
  source = "../../modules/net-iap"

  project_id = var.project_id

  tunnel_instance_bindings = {
    bastion = {
      zone     = "asia-southeast2-a"
      instance = "bastion-host"
      members  = ["group:sre@example.com"]
    }
  }

  web_backend_bindings = {
    app = {
      web_backend_service = "app-backend"
      members             = ["domain:example.com"]
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/net-iap test -no-color
```

Scenarios:

* `plan_tunnel` — tunnel instance bindings + additive members, default role
* `plan_web_backend` — web backend bindings, default role
* `plan_with_brand` — count-guarded brand + OAuth client, and brand-off-by-default
* `plan_negative` — brand-without-config, client-without-brand, client-without-config

---

## Requirements

Requires Terraform **≥ 1.9** (cross-variable validation conditions).

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L1) | The project ID where IAP resources and bindings are managed. | <code>string</code> | ✓ |  |
| [brand](variables.tf#L17) | IAP OAuth brand configuration. Required when create_brand is true. | <code title="object&#40;&#123;&#10;  support_email     &#61; string&#10;  application_title &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [create_brand](variables.tf#L11) | Whether to create the project-level IAP OAuth brand. At most one brand may exist per project, so keep this false in modules that may run repeatedly. | <code>bool</code> |  | <code>false</code> |
| [create_client](variables.tf#L31) | Whether to create an IAP OAuth client under the brand. Requires create_brand = true. | <code>bool</code> |  | <code>false</code> |
| [oauth_client](variables.tf#L42) | IAP OAuth client configuration. Required when create_client is true. | <code title="object&#40;&#123;&#10;  display_name &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [tunnel_instance_bindings](variables.tf#L57) | Authoritative IAP tunnel IAM bindings per instance, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  zone     &#61; string&#10;  instance &#61; string&#10;  role     &#61; optional&#40;string, &#34;roles&#47;iap.tunnelResourceAccessor&#34;&#41;&#10;  members  &#61; list&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [tunnel_instance_members](variables.tf#L69) | Additive IAP tunnel IAM members per instance, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  zone     &#61; string&#10;  instance &#61; string&#10;  role     &#61; optional&#40;string, &#34;roles&#47;iap.tunnelResourceAccessor&#34;&#41;&#10;  member   &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [web_backend_bindings](variables.tf#L83) | Authoritative IAP web backend service IAM bindings, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  web_backend_service &#61; string&#10;  role                &#61; optional&#40;string, &#34;roles&#47;iap.httpsResourceAccessor&#34;&#41;&#10;  members             &#61; list&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [web_backend_members](variables.tf#L94) | Additive IAP web backend service IAM members, keyed by a logical name. | <code title="map&#40;object&#40;&#123;&#10;  web_backend_service &#61; string&#10;  role                &#61; optional&#40;string, &#34;roles&#47;iap.httpsResourceAccessor&#34;&#41;&#10;  member              &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [brand_name](outputs.tf#L1) | Resource name of the IAP brand, if created (else null). |  |
| [oauth_client_id](outputs.tf#L6) | OAuth client ID, if a client was created (else null). |  |
| [oauth_client_secret](outputs.tf#L11) | OAuth client secret, if a client was created (else null). | ✓ |
| [tunnel_instance_bindings](outputs.tf#L17) | Map of created IAP tunnel instance IAM bindings. |  |
| [web_backend_bindings](outputs.tf#L22) | Map of created IAP web backend service IAM bindings. |  |
<!-- END TFDOC -->
