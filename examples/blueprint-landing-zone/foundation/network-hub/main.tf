/**
 * # Landing Zone - Layer 02: Networking Hub
 *
 * This layer sets up the Shared VPC (Hub) and core networking services.
 */

# 1. Networking Project (Host Project)
resource "google_project" "network_hub" {
  name            = "org-network-hub"
  project_id      = "org-net-hub-${formatdate("YYYYMMDD", timestamp())}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  labels          = var.default_labels
}

resource "google_compute_shared_vpc_host_project" "host" {
  project    = google_project.network_hub.project_id
  depends_on = [google_project_service.compute]
}

resource "google_project_service" "compute" {
  project = google_project.network_hub.project_id
  service = "compute.googleapis.com"
}

# 2. Shared VPC Config
module "vpc_hub" {
  source = "../../../../modules/net-vpc"

  networks = {
    hub-vpc = {
      name    = "hub-vpc"
      project = google_project.network_hub.project_id
    }
  }

  subnetworks = {
    hub-mgmt-subnet = {
      name          = "hub-mgmt-subnet"
      network       = "hub-vpc"
      ip_cidr_range = "10.128.0.0/24"
      region        = var.region
      project       = google_project.network_hub.project_id
    }
  }

  compute_routes = {}
}

# 3. Cloud NAT for Hub
module "nat" {
  source = "../../../../modules/net-cloudnat"

  compute_router_nats = {
    hub-nat = {
      name                               = "hub-nat"
      project                            = google_project.network_hub.project_id
      region                             = var.region
      router                             = "hub-router"
      nat_ip_allocate_option             = "AUTO_ONLY"
      nat_ips                            = []
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      log_config = {
        enable = true
      }
    }
  }

  nat_ip_lookup = {}
  network_lookup = {
    hub-vpc = { self_link = module.vpc_hub.networks["hub-vpc"].self_link }
  }
  router_lookup = {
    hub-router = { name = "hub-router" }
  }
}

output "host_project_id" {
  value = google_project.network_hub.project_id
}

output "network_self_link" {
  value = module.vpc_hub.networks["hub-vpc"].self_link
}
