/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ------------------------------------------------------------------------------
# VPC and Subnets
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/net-vpc"

  networks = {
    "web-vpc" = {
      project                 = var.project_id
      name                    = "web-vpc"
      auto_create_subnetworks = false
    }
  }

  subnetworks = {
    "web-subnet" = {
      project       = var.project_id
      name          = "web-subnet"
      network       = "web-vpc"
      region        = var.region
      ip_cidr_range = "10.0.0.0/24"
    }
  }

  compute_routes = {}
}

# ------------------------------------------------------------------------------
# Cloud Armor Security Policy
# ------------------------------------------------------------------------------
module "cloud_armor" {
  source = "../../modules/net-security-policy"

  compute_security_policies = {
    "web-armor-policy" = {
      name        = "web-armor-policy"
      project     = var.project_id
      description = "Security policy to whitelist specific IPs"

      rules = {
        "deny_all" = {
          action      = "deny(403)"
          priority    = 2147483647
          match       = { versioned_expr = "SRC_IPS_V1", config = { src_ip_ranges = ["*"] } }
          description = "Default deny all"
        }
        "whitelist_ips" = {
          action      = "allow"
          priority    = 1000
          match       = { versioned_expr = "SRC_IPS_V1", config = { src_ip_ranges = var.whitelist_ips } }
          description = "Whitelist company IPs"
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Custom Service Account for Web Servers
# ------------------------------------------------------------------------------
module "web_sa" {
  source       = "../../modules/iam-service-accounts"
  project_id   = var.project_id
  account_id   = "web-srv-sa-e2e"
  display_name = "Hardened Web Server Service Account"

  labels = var.default_labels
}

# ------------------------------------------------------------------------------
# Instance Template (via compute-vm module)
# ------------------------------------------------------------------------------
module "compute_template" {
  source     = "../../modules/compute-vm"
  project_id = var.project_id
  zone       = "${var.region}-a"

  compute_instance_templates = {
    "web-template" = {
      name         = "web-template"
      machine_type = "e2-medium"

      disk = [{
        auto_delete  = true
        boot         = true
        source_image = "debian"
        type         = "pd-balanced"
        disk_encryption_key = {
          kms_key_self_link = var.kms_key_name
        }
      }]

      network_interface = [{
        subnetwork = module.vpc.subnetworks["web-subnet"].self_link
      }]

      service_account = {
        email  = module.web_sa.email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
      }

      metadata_startup_script = "web-startup"
      tags                    = ["http-server"]
      scheduling              = {}
    }
  }

  data_compute_images = {
    "debian" = {
      name    = "debian-12"
      family  = "debian-12"
      project = "debian-cloud"
    }
  }

  templatefiles = {
    "web-startup" = {
      template = "${path.module}/startup.sh"
      vars     = {}
    }
  }

  default_labels = var.default_labels
}

# ------------------------------------------------------------------------------
# Managed Instance Group (MIG) for Backend
# ------------------------------------------------------------------------------
module "web_mig" {
  source = "../../modules/compute-mig"

  project_id = var.project_id
  location   = var.region
  name       = "web-servers"

  instance_template = module.compute_template.compute_instance_templates["web-template"].self_link

  autoscaler_config = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60
    scaling_signals = {
      cpu_utilization = {
        target = 0.6
      }
    }
  }

  health_check_config = {
    http = {
      port = 80
    }
  }
}

# ------------------------------------------------------------------------------
# Global SSL Certificate
# ------------------------------------------------------------------------------
module "ssl_cert" {
  source = "../../modules/ssl-certificate"

  compute_managed_ssl_certificates = {
    "web-cert" = {
      name    = "web-ssl-cert"
      project = var.project_id
      managed = {
        domains = [var.domain_name]
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Global External HTTPS Load Balancer
# ------------------------------------------------------------------------------
module "lb" {
  source = "../../modules/net-lb"

  resource_prefix = "web-lb"

  compute_health_checks = {
    "web-hc" = {
      project = var.project_id
      name    = "web-hc"
      http_health_check = {
        port = 80
      }
    }
  }

  compute_backend_services = {
    "web-backend" = {
      project               = var.project_id
      name                  = "web-backend"
      protocol              = "HTTP"
      port_name             = "http"
      load_balancing_scheme = "EXTERNAL_MANAGED"
      health_checks         = ["web-hc"]
      security_policy       = module.cloud_armor.security_policies["web-armor-policy"].self_link

      backends = [{
        group = module.web_mig.instance_group
      }]
    }
  }

  compute_url_maps = {
    "web-map" = {
      project         = var.project_id
      name            = "web-map"
      default_service = "web-backend"
    }
  }

  compute_target_https_proxies = {
    "web-proxy" = {
      project          = var.project_id
      name             = "web-proxy"
      url_map          = "web-map"
      ssl_certificates = [module.ssl_cert.managed_ssl_certificates["web-cert"].id]
    }
  }

  compute_global_forwarding_rules = {
    "web-fw-rule" = {
      project               = var.project_id
      name                  = "web-fw-rule"
      target                = "web-proxy"
      port_range            = "443"
      load_balancing_scheme = "EXTERNAL_MANAGED"
      ip_address            = google_compute_global_address.web_ip.address
    }
  }

  default_labels = var.default_labels
}

# Reserved IP for LB
resource "google_compute_global_address" "web_ip" {
  project = var.project_id
  name    = "web-ip"
}
