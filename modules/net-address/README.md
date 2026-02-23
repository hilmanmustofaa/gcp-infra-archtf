# Net Address Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module provisions and manages IP address resources in GCP: external, internal, global, VPC‐peering (PSA), and IPSEC interconnect addresses. It consolidates all address types under one interface, handling naming, regions, subnetworks, purposes, prefix lengths, labels and more.

# Feature
- **Multi‐Type Address Allocation**: create/claim EXTERNAL, INTERNAL, GLOBAL, VPC_PEERING and IPSEC_INTERCONNECT addresses.  
- **Flexible Naming**: each map key can override the default name or you can supply a custom one.  
- **Custom Configuration**: specify region, subnetwork, purpose, prefix_length, address or let GCP auto‐assign.  
- **Labels & Descriptions**: merge default labels with custom map entries for consistent tagging.  
- **Single‐Module Management**: handle all address types together, reducing duplication.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L60) | The GCP project ID. | <code>string</code> | ✓ |  |
| [default_labels](variables.tf#L1) | Default labels to apply to all resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [external_addresses](variables.tf#L7) | Map of external IP addresses. | <code title="map&#40;object&#40;&#123;&#10;  name         &#61; optional&#40;string&#41;&#10;  region       &#61; string&#10;  address      &#61; optional&#40;string&#41;&#10;  description  &#61; optional&#40;string&#41;&#10;  labels       &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  network_tier &#61; optional&#40;string&#41;&#10;  subnetwork   &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [global_addresses](variables.tf#L21) | Map of global IP addresses. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; optional&#40;string&#41;&#10;  description &#61; optional&#40;string&#41;&#10;  ip_version  &#61; optional&#40;string&#41;&#10;  labels      &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [internal_addresses](variables.tf#L32) | Map of internal IP addresses. | <code title="map&#40;object&#40;&#123;&#10;  name        &#61; optional&#40;string&#41;&#10;  region      &#61; string&#10;  address     &#61; optional&#40;string&#41;&#10;  description &#61; optional&#40;string&#41;&#10;  subnetwork  &#61; string&#10;  labels      &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  purpose     &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [ipsec_interconnect_addresses](variables.tf#L46) | Map of IP addresses for IPSEC Interconnect. | <code title="map&#40;object&#40;&#123;&#10;  name          &#61; optional&#40;string&#41;&#10;  description   &#61; optional&#40;string&#41;&#10;  address       &#61; string&#10;  region        &#61; string&#10;  network       &#61; string&#10;  prefix_length &#61; number&#10;  labels        &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L71) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [psa_addresses](variables.tf#L77) | Map of Private Service Access addresses. | <code title="map&#40;object&#40;&#123;&#10;  name          &#61; optional&#40;string&#41;&#10;  description   &#61; optional&#40;string&#41;&#10;  address       &#61; string&#10;  network       &#61; string&#10;  prefix_length &#61; number&#10;  labels        &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L65) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [external_addresses](outputs.tf#L1) | Allocated external addresses. |  |
| [global_addresses](outputs.tf#L9) | Allocated global external addresses. |  |
| [internal_addresses](outputs.tf#L17) | Allocated internal addresses. |  |
| [ipsec_interconnect_addresses](outputs.tf#L25) | Allocated internal addresses for HPA VPN over Cloud Interconnect. |  |
| [psa_addresses](outputs.tf#L33) | Allocated internal addresses for PSA endpoints. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "net_address" {
  source = "git::ssh://git@gitlab.com/your-org/terraform-modules.git//modules/gcp/network/net-address?ref=v1.0.0"

  project_id = "my-project"

  external_addresses = {
    public-ip = {
      region  = "us-central1"
      address = "34.120.1.2"
    }
    auto-ip = {
      region = "us-east1"
    }
  }

  internal_addresses = {
    private-ip = {
      region     = "us-central1"
      subnetwork = "default"
      purpose    = "INTERNAL_HTTPS_LOAD_BALANCER"
    }
  }

  global_addresses = {
    global-v4 = {}
  }

  psa_addresses = {
    psa-peer = {
      network       = "projects/my-project/global/networks/peered-vpc"
      prefix_length = 16
    }
  }

  ipsec_interconnect_addresses = {
    ipsec-peer = {
      network       = "projects/my-project/global/networks/edge-network"
      region        = "us-central1"
      prefix_length = 24
    }
  }
}
