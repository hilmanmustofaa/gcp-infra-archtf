# VPC Service Controls Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Features](#features)
- [Security & Compliance Notes](#security-compliance-notes)
- [Example Usage](#example-usage)
- [Testing](#testing)
- [Variables](#variables)
- [Outputs](#outputs)
<!-- END TOC -->

## Description

Builds [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/overview) — Access Context Manager access levels and service perimeters — from a map-driven interface. This is the primary **data-exfiltration control** for banking (OJK) and government (data-residency) engagements: it draws a security boundary around projects so restricted APIs (BigQuery, GCS, etc.) can only be reached from inside the perimeter or through explicit ingress/egress rules.

Pairs with the `e2e-secured-data-tier` blueprint and the `bq-dataset` / `gcs` modules to enclose the data tier.

---

## Features

✅ **Access policy** — reference an existing `accessPolicies/<id>` or optionally create one (`create_access_policy`).

✅ **Access levels (basic)** — map of levels with `ip_subnetworks`, `regions`, `members`, `required_access_levels`, `negate`, and `AND`/`OR` combining.

✅ **Service perimeters** — `resources`, `restricted_services`, `access_levels`, and `vpc_accessible_services` restriction.

✅ **Ingress / egress policies** — fine-grained `from`/`to` rules with identities, sources, and per-service operation/method selectors for controlled data flow across the boundary.

✅ **Logical-key resolution** — perimeters reference access levels by this module's logical key (resolved to full names) or by literal name.

✅ **Validation** — ACM-safe keys (underscore-only) and FinOps governance metadata enforced.

---

## Security & Compliance Notes

- **OJK / data residency:** enclose data-tier projects and set `restricted_services` to the storage/analytics APIs; combine with a `corp` access level pinned to `regions = ["ID"]` and trusted `ip_subnetworks`.
- **Least exposure:** keep `vpc_accessible_services.enable_restriction = true` and list only the services the workload needs.
- **Controlled exchange:** use `ingress_policies` / `egress_policies` instead of widening `access_levels` — scope each rule to specific identities, source/target projects, and service methods.
- **Org-scoped resources:** access policies, levels, and perimeters are not project-scoped and carry no labels; FinOps metadata is exposed via the `finops_labels` output for inventory only.
- **Roll out safely:** apply perimeters to a non-prod project first (or use a dry-run perimeter outside this module) before enforcing on production — a misconfigured perimeter can block legitimate access.

---

## Example Usage

```hcl
module "vpcsc" {
  source = "../../modules/vpc-service-controls"

  access_policy_id = "accessPolicies/123456789"

  default_labels = {
    env     = "prod"
    project = "secure-data"
    owner   = "security-team"
  }

  access_levels = {
    corp = {
      title      = "Corp network (ID only)"
      conditions = [{ ip_subnetworks = ["203.0.113.0/24"], regions = ["ID"] }]
    }
  }

  service_perimeters = {
    data = {
      title               = "Secured data tier"
      resources           = ["projects/123456789"]
      restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com"]
      access_levels       = ["corp"]
      vpc_accessible_services = {
        enable_restriction = true
        allowed_services   = ["bigquery.googleapis.com", "storage.googleapis.com"]
      }
    }
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

---

## Testing

```bash
terraform -chdir=modules/vpc-service-controls test -no-color
```

Scenarios:

* `plan_basic` — access level naming, perimeter access-level resolution, restricted services; plus ingress/egress policies
* `plan_negative` — missing FinOps labels, dashed access-level key, dashed perimeter key

---
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [default_labels](variables.tf#L1) | Governance metadata. Must include 'env', 'project', and 'owner' for FinOps consistency. Note: Access Context Manager resources are org-scoped and do not carry labels; this is exposed via the finops_labels output only. | <code>map&#40;string&#41;</code> | ✓ |  |
| [access_levels](variables.tf#L30) | Map of Access Levels (basic), keyed by a short name (used as the access level id). | <code title="map&#40;object&#40;&#123;&#10;  title              &#61; string&#10;  description        &#61; optional&#40;string&#41;&#10;  combining_function &#61; optional&#40;string, &#34;AND&#34;&#41; &#35; AND &#124; OR&#10;  conditions &#61; list&#40;object&#40;&#123;&#10;    ip_subnetworks         &#61; optional&#40;list&#40;string&#41;&#41;&#10;    required_access_levels &#61; optional&#40;list&#40;string&#41;&#41;&#10;    members                &#61; optional&#40;list&#40;string&#41;&#41;&#10;    regions                &#61; optional&#40;list&#40;string&#41;&#41;&#10;    negate                 &#61; optional&#40;bool&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [access_policy_id](variables.tf#L15) | Existing Access Context Manager access policy id (e.g. 'accessPolicies/123456'). Required unless create_access_policy is set. Parent for all access levels and perimeters. | <code>string</code> |  | <code>null</code> |
| [create_access_policy](variables.tf#L21) | Optionally create the org/folder-scoped access policy instead of referencing an existing one. Requires org-level permissions. | <code title="object&#40;&#123;&#10;  parent &#61; string &#35; e.g. &#34;organizations&#47;123456789&#34;&#10;  title  &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [service_perimeters](variables.tf#L53) | Map of Service Perimeters, keyed by a short name (used as the perimeter id). | <code title="map&#40;object&#40;&#123;&#10;  title          &#61; string&#10;  description    &#61; optional&#40;string&#41;&#10;  perimeter_type &#61; optional&#40;string, &#34;PERIMETER_TYPE_REGULAR&#34;&#41; &#35; REGULAR &#124; BRIDGE&#10;&#10;&#10;  resources           &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41; &#35; &#91;&#34;projects&#47;123456789&#34;&#93;&#10;  restricted_services &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41; &#35; &#91;&#34;bigquery.googleapis.com&#34;, ...&#93;&#10;  access_levels       &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41; &#35; access level logical keys &#40;this module&#41; or full names&#10;&#10;&#10;  vpc_accessible_services &#61; optional&#40;object&#40;&#123;&#10;    enable_restriction &#61; bool&#10;    allowed_services   &#61; list&#40;string&#41; &#35; service names or &#91;&#34;RESTRICTED-SERVICES&#34;&#93;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  ingress_policies &#61; optional&#40;list&#40;object&#40;&#123;&#10;    from &#61; object&#40;&#123;&#10;      identity_type &#61; optional&#40;string&#41; &#35; ANY_IDENTITY &#124; ANY_USER_ACCOUNT &#124; ANY_SERVICE_ACCOUNT&#10;      identities    &#61; optional&#40;list&#40;string&#41;&#41;&#10;      sources &#61; optional&#40;list&#40;object&#40;&#123;&#10;        access_level &#61; optional&#40;string&#41; &#35; access level logical key or full name&#10;        resource     &#61; optional&#40;string&#41; &#35; &#34;projects&#47;123&#34; or &#34;&#42;&#34;&#10;      &#125;&#41;&#41;, &#91;&#93;&#41;&#10;    &#125;&#41;&#10;    to &#61; object&#40;&#123;&#10;      resources &#61; optional&#40;list&#40;string&#41;, &#91;&#34;&#42;&#34;&#93;&#41;&#10;      operations &#61; optional&#40;list&#40;object&#40;&#123;&#10;        service_name &#61; string&#10;        methods      &#61; optional&#40;list&#40;string&#41;, &#91;&#34;&#42;&#34;&#93;&#41;&#10;      &#125;&#41;&#41;, &#91;&#93;&#41;&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;, &#91;&#93;&#41;&#10;&#10;&#10;  egress_policies &#61; optional&#40;list&#40;object&#40;&#123;&#10;    from &#61; object&#40;&#123;&#10;      identity_type &#61; optional&#40;string&#41;&#10;      identities    &#61; optional&#40;list&#40;string&#41;&#41;&#10;    &#125;&#41;&#10;    to &#61; object&#40;&#123;&#10;      resources          &#61; optional&#40;list&#40;string&#41;, &#91;&#34;&#42;&#34;&#93;&#41;&#10;      external_resources &#61; optional&#40;list&#40;string&#41;&#41;&#10;      operations &#61; optional&#40;list&#40;object&#40;&#123;&#10;        service_name &#61; string&#10;        methods      &#61; optional&#40;list&#40;string&#41;, &#91;&#34;&#42;&#34;&#93;&#41;&#10;      &#125;&#41;&#41;, &#91;&#93;&#41;&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;, &#91;&#93;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [access_level_names](outputs.tf#L6) | Map of logical key => full access level resource name. |  |
| [access_policy_name](outputs.tf#L1) | The access policy name used as parent (created or referenced). |  |
| [finops_labels](outputs.tf#L16) | FinOps label package for this module, to be merged with workspace-level defaults. |  |
| [service_perimeter_names](outputs.tf#L11) | Map of logical key => full service perimeter resource name. |  |
<!-- END TFDOC -->
