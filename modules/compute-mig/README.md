# Compute Managed Instance Group Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module provisions both zonal and regional Google Compute Instance Group Managers (MIGs), unmanaged instance groups, health checks, per-instance stateful configuration, and optional autoscalers. It supports multi-version deployments, auto-healing, rolling update controls, named ports, custom metrics and schedules, and deep integration with Cloud Monitoring and health-check resources.

# Feature
- **Zonal & Regional MIGs**: automatically selects the right resource type based on `var.location`.  
- **Multi-version deployments**: deploy multiple instance template versions with size overrides.  
- **Auto-healing**: hook into GCP Health Checks or your own checks for self-healing.  
- **Rolling update policies**: fine-grained control over surge and unavailable counts.  
- **Named ports**: expose container or VM ports by name.  
- **Health Checks**: create and configure HTTP, HTTPS, TCP, SSL, HTTP2, and gRPC health checks.  
- **Autoscaling**: zonal and regional autoscalers driven by CPU, load-balancing, custom metrics, and cron schedules.  
- **Stateful per-instance configs**: preserve disks and metadata across rolling updates.  
- **Unmanaged instance groups**: support for plain `google_compute_instance_group` if needed.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [instance_template](variables.tf#L115) | The self_link of the instance template to use. | <code>string</code> | ✓ |  |
| [location](variables.tf#L126) | The location (region or zone) where resources will be created. Use a zone name for zonal resources and a region name for regional. | <code>string</code> | ✓ |  |
| [name](variables.tf#L131) | The base name for all resources created by this module. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L142) | The ID of the GCP project where resources will be created. | <code>string</code> | ✓ |  |
| [auto_healing_policies](variables.tf#L1) | Auto-healing configuration. | <code title="object&#40;&#123;&#10;  health_check      &#61; optional&#40;string&#41;&#10;  initial_delay_sec &#61; number&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [autoscaler_config](variables.tf#L10) | Autoscaling configuration. | <code title="object&#40;&#123;&#10;  max_replicas    &#61; number&#10;  min_replicas    &#61; number&#10;  cooldown_period &#61; optional&#40;number&#41;&#10;  mode            &#61; optional&#40;string&#41;&#10;&#10;&#10;  scaling_control &#61; optional&#40;object&#40;&#123;&#10;    down &#61; optional&#40;object&#40;&#123;&#10;      time_window_sec      &#61; optional&#40;number&#41;&#10;      max_replicas_fixed   &#61; optional&#40;number&#41;&#10;      max_replicas_percent &#61; optional&#40;number&#41;&#10;    &#125;&#41;&#41;&#10;    in &#61; optional&#40;object&#40;&#123;&#10;      time_window_sec      &#61; optional&#40;number&#41;&#10;      max_replicas_fixed   &#61; optional&#40;number&#41;&#10;      max_replicas_percent &#61; optional&#40;number&#41;&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#10;&#10;  scaling_signals &#61; optional&#40;object&#40;&#123;&#10;    cpu_utilization &#61; optional&#40;object&#40;&#123;&#10;      target                &#61; number&#10;      optimize_availability &#61; optional&#40;bool&#41;&#10;    &#125;&#41;&#41;&#10;    load_balancing_utilization &#61; optional&#40;object&#40;&#123;&#10;      target &#61; number&#10;    &#125;&#41;&#41;&#10;    metrics &#61; optional&#40;list&#40;object&#40;&#123;&#10;      name                       &#61; string&#10;      type                       &#61; string&#10;      target_value               &#61; number&#10;      single_instance_assignment &#61; optional&#40;number&#41;&#10;      time_series_filter         &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;&#41;&#10;    schedules &#61; optional&#40;list&#40;object&#40;&#123;&#10;      duration_sec          &#61; number&#10;      name                  &#61; string&#10;      cron_schedule         &#61; string&#10;      description           &#61; optional&#40;string&#41;&#10;      disabled              &#61; optional&#40;bool&#41;&#10;      timezone              &#61; optional&#40;string&#41;&#10;      min_required_replicas &#61; number&#10;    &#125;&#41;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [compute_instance_groups](variables.tf#L60) | Configuration for unmanaged instance groups. | <code title="map&#40;object&#40;&#123;&#10;  name                &#61; string&#10;  description         &#61; optional&#40;string&#41;&#10;  zone                &#61; string&#10;  network_self_link   &#61; string&#10;  instance_self_links &#61; list&#40;string&#41;&#10;  named_port          &#61; optional&#40;map&#40;number&#41;&#41;&#10;  project             &#61; optional&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [default_version_name](variables.tf#L74) | Name of the default instance template version. | <code>string</code> |  | <code>&#34;default&#34;</code> |
| [description](variables.tf#L80) | An optional description for the managed instance group. | <code>string</code> |  | <code>null</code> |
| [distribution_policy](variables.tf#L86) | Regional MIG distribution policy config. | <code title="object&#40;&#123;&#10;  target_shape &#61; optional&#40;string&#41;&#10;  zones        &#61; optional&#40;list&#40;string&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [health_check_config](variables.tf#L95) | Optional health check config block. | <code title="object&#40;&#123;&#10;  description         &#61; optional&#40;string&#41;&#10;  check_interval_sec  &#61; optional&#40;number&#41;&#10;  timeout_sec         &#61; optional&#40;number&#41;&#10;  healthy_threshold   &#61; optional&#40;number&#41;&#10;  unhealthy_threshold &#61; optional&#40;number&#41;&#10;  enable_logging      &#61; optional&#40;bool&#41;&#10;&#10;&#10;  http  &#61; optional&#40;object&#40;&#123; host &#61; optional&#40;string&#41;, request_path &#61; optional&#40;string&#41;, response &#61; optional&#40;string&#41;, port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, proxy_header &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;  https &#61; optional&#40;object&#40;&#123; host &#61; optional&#40;string&#41;, request_path &#61; optional&#40;string&#41;, response &#61; optional&#40;string&#41;, port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, proxy_header &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;  tcp   &#61; optional&#40;object&#40;&#123; port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, proxy_header &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41;, request &#61; optional&#40;string&#41;, response &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;  ssl   &#61; optional&#40;object&#40;&#123; port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, proxy_header &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41;, request &#61; optional&#40;string&#41;, response &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;  http2 &#61; optional&#40;object&#40;&#123; host &#61; optional&#40;string&#41;, request_path &#61; optional&#40;string&#41;, response &#61; optional&#40;string&#41;, port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, proxy_header &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;  grpc  &#61; optional&#40;object&#40;&#123; port &#61; optional&#40;number&#41;, port_name &#61; optional&#40;string&#41;, port_specification &#61; optional&#40;string&#41;, service_name &#61; optional&#40;string&#41; &#125;&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [join_separator](variables.tf#L120) | String to join prefix and name. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [named_ports](variables.tf#L136) | Map of named ports (e.g. http = 80). | <code>map&#40;number&#41;</code> |  | <code>null</code> |
| [resource_prefix](variables.tf#L147) | Prefix to prepend to resource names. | <code>string</code> |  | <code>null</code> |
| [stateful_config](variables.tf#L153) | Stateful per-instance configuration map. | <code title="map&#40;object&#40;&#123;&#10;  minimal_action          &#61; string&#10;  most_disruptive_action  &#61; string&#10;  remove_state_on_destroy &#61; bool&#10;  preserved_state &#61; optional&#40;object&#40;&#123;&#10;    metadata &#61; optional&#40;map&#40;string&#41;&#41;&#10;    disks &#61; optional&#40;map&#40;object&#40;&#123;&#10;      source                      &#61; string&#10;      delete_on_instance_deletion &#61; optional&#40;bool&#41;&#10;      read_only                   &#61; optional&#40;bool&#41;&#10;    &#125;&#41;&#41;&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [stateful_disks](variables.tf#L171) | Map of stateful disk device names and persistence flags. | <code>map&#40;bool&#41;</code> |  | <code>&#123;&#125;</code> |
| [target_pools](variables.tf#L177) | List of target pools to attach. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [target_size](variables.tf#L183) | Target size of the instance group. | <code>number</code> |  | <code>null</code> |
| [update_policy](variables.tf#L189) | Update policy for rolling updates. | <code title="object&#40;&#123;&#10;  minimal_action &#61; string&#10;  type           &#61; string&#10;  max_surge &#61; optional&#40;object&#40;&#123;&#10;    fixed   &#61; optional&#40;number&#41;&#10;    percent &#61; optional&#40;number&#41;&#10;  &#125;&#41;&#41;&#10;  max_unavailable &#61; optional&#40;object&#40;&#123;&#10;    fixed   &#61; optional&#40;number&#41;&#10;    percent &#61; optional&#40;number&#41;&#10;  &#125;&#41;&#41;&#10;  min_ready_sec                &#61; optional&#40;number&#41;&#10;  replacement_method           &#61; optional&#40;string&#41;&#10;  most_disruptive_action       &#61; optional&#40;string&#41;&#10;  regional_redistribution_type &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [versions](variables.tf#L210) | Additional instance template versions with optional size overrides. | <code title="map&#40;object&#40;&#123;&#10;  instance_template &#61; string&#10;  target_size &#61; optional&#40;object&#40;&#123;&#10;    fixed   &#61; optional&#40;number&#41;&#10;    percent &#61; optional&#40;number&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [wait_for_instances](variables.tf#L222) | Whether to wait for instances and expected status. | <code title="object&#40;&#123;&#10;  enabled &#61; bool&#10;  status  &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  enabled &#61; false&#10;&#125;">&#123;&#8230;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [autoscaler_id](outputs.tf#L2) | The identifier of the autoscaler. |  |
| [autoscaler_self_link](outputs.tf#L11) | The self-link of the autoscaler. |  |
| [health_check_id](outputs.tf#L21) | The identifier of the health check. |  |
| [health_check_self_link](outputs.tf#L26) | The self-link of the health check. |  |
| [instance_group](outputs.tf#L32) | The instance group URL of the managed instance group. |  |
| [name](outputs.tf#L41) | The name of the managed instance group. |  |
| [self_link](outputs.tf#L50) | The self-link of the managed instance group. |  |
| [stateful_configs](outputs.tf#L60) | Map of stateful configuration details. |  |
| [status](outputs.tf#L81) | Status of the managed instance group. |  |
<!-- END TFDOC -->
# Example Usage
```hcl
module "compute_mig" {
  source            = "./modules/gcp/compute/compute-mig"
  project_id        = "my-project"
  location          = "us-central1-a"       # or "us-central1" for regional
  name              = "app-mig"
  instance_template = "projects/my-project/global/instanceTemplates/app-template"
  target_size       = 3
  target_pools      = []

  # Health check
  health_check_config = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    http = {
      port         = 8080
      request_path = "/healthz"
    }
  }

  auto_healing_policies = {
    initial_delay_sec = 300
    # if you set health_check here it will override the above-created health_check
  }

  update_policy = {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    max_surge             = { fixed = 1 }
    max_unavailable       = { percent = 20 }
    most_disruptive_action = "RECREATE"
  }

  named_ports = {
    http = 80
    grpc = 9090
  }

  # Optional autoscaler 
  autoscaler_config = {
    min_replicas             = 1
    max_replicas             = 5
    cooldown_period          = 60
    cpu_utilization          = { target = 0.6 }
    load_balancing_utilization = { target = 0.8 }
    schedules = {
      nightly = {
        name                  = "nightly"
        cron_schedule         = "0 2 * * *"
        duration_sec          = 3600
        min_required_replicas = 2
      }
    }
  }

  # Stateful configuration
  stateful_config = {
    "instance-1" = {
      minimal_action                = "RESTART"
      most_disruptive_action        = "RECREATE"
      remove_state_on_destroy       = true
      preserved_state = {
        metadata = { role = "db-primary" }
        disks = {
          "data-disk" = {
            source                      = "projects/my-project/zones/us-central1-a/disks/data-disk"
            delete_on_instance_deletion = true
            read_only                   = false
          }
        }
      }
    }
  }

  # Unmanaged instance groups (optional)
  compute_instance_groups = {
    ug1 = {
      name              = "legacy-ig"
      zone              = "us-central1-a"
      network_self_link = "projects/my-project/global/networks/default"
      instance_self_links = [
        "projects/my-project/zones/us-central1-a/instances/old-vm-1",
        "projects/my-project/zones/us-central1-a/instances/old-vm-2",
      ]
    }
  }
}
