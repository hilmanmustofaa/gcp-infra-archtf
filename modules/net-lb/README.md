# Load Balancing Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module manages Google Cloud Load Balancing resources, including health checks, regional health checks, backend services, regional backend services, URL maps, target HTTPS proxies, global forwarding rules, and regional forwarding rules.

# Feature
- **Health Checks**: create health checks for backend services.
- **Regional Health Checks**: create regional health checks for regional backend services.
- **Backend Services**: create backend services for load balancers.
- **Regional Backend Services**: create regional backend services for regional load balancers.
- **URL Maps**: create URL maps for HTTP(S) load balancers.
- **Target HTTPS Proxies**: create target HTTPS proxies for HTTPS load balancers.
- **Global Forwarding Rules**: create global forwarding rules for external HTTP(S) load balancers.
- **Regional Forwarding Rules**: create regional forwarding rules for internal load balancers.
- **Flexible Naming**: support `resource_prefix` and `join_separator` for consistent naming conventions.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [compute_backend_services](variables.tf#L1) | A map of backend service objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_forwarding_rules](variables.tf#L9) | A map of forwarding rule objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_global_forwarding_rules](variables.tf#L15) | A map of global forwarding rule objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_health_checks](variables.tf#L21) | A map of health check objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_region_backend_services](variables.tf#L27) | A map of regional backend service objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_region_health_checks](variables.tf#L33) | A map of regional health check objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_target_https_proxies](variables.tf#L39) | A map of target HTTPS proxy objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [compute_url_maps](variables.tf#L45) | A map of URL map objects. | <code>any</code> |  | <code>&#123;&#125;</code> |
| [default_labels](variables.tf#L51) | Default labels to apply to all resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L57) | The separator to use when joining the prefix and the name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [resource_prefix](variables.tf#L63) | A prefix for the resource names. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [backend_services](outputs.tf#L1) | The created backend services. |  |
| [forwarding_rules](outputs.tf#L6) | The created forwarding rules. |  |
| [global_forwarding_rules](outputs.tf#L11) | The created global forwarding rules. |  |
| [health_checks](outputs.tf#L16) | The created health checks. |  |
| [region_backend_services](outputs.tf#L21) | The created regional backend services. |  |
| [region_health_checks](outputs.tf#L26) | The created regional health checks. |  |
| [target_https_proxies](outputs.tf#L31) | The created target HTTPS proxies. |  |
| [url_maps](outputs.tf#L36) | The created URL maps. |  |
<!-- END TFDOC -->
# Example Usage

```hcl
module "lb" {
  source = "./modules/net-lb"

  compute_health_checks = {
    "http-health-check" = {
      name                = "http-health-check"
      check_interval_sec  = 5
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      health_check = {
        protocol = "HTTP"
        port     = 80
        request_path = "/"
      }
      project = "my-project"
    }
  }

  compute_backend_services = {
    "my-backend-service" = {
      name        = "my-backend-service"
      protocol    = "HTTP"
      port_name   = "http"
      health_checks = ["http-health-check"]
      project     = "my-project"
      backend = [
        {
          group = "instance-group-self-link"
        }
      ]
    }
  }

  compute_url_maps = {
    "my-url-map" = {
      name            = "my-url-map"
      default_service = "my-backend-service"
      project         = "my-project"
    }
  }

  compute_target_https_proxies = {
    "my-https-proxy" = {
      name             = "my-https-proxy"
      url_map          = "my-url-map"
      ssl_certificates = ["ssl-certificate-self-link"]
      project          = "my-project"
    }
  }

  compute_global_forwarding_rules = {
    "my-global-forwarding-rule" = {
      name        = "my-global-forwarding-rule"
      ip_protocol = "TCP"
      port_range  = "443"
      target      = "my-https-proxy"
      project     = "my-project"
    }
  }

  compute_region_health_checks = {
    "http-region-health-check" = {
      name                = "http-region-health-check"
      check_interval_sec  = 5
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      health_check = {
        protocol = "HTTP"
        port     = 80
        request_path = "/"
      }
      region  = "us-central1"
      project = "my-project"
    }
  }

  compute_region_backend_services = {
    "my-region-backend-service" = {
      name        = "my-region-backend-service"
      protocol    = "HTTP"
      port_name   = "http"
      health_checks = ["http-region-health-check"]
      region      = "us-central1"
      project     = "my-project"
      backend = [
        {
          group = "instance-group-self-link"
        }
      ]
    }
  }
}
