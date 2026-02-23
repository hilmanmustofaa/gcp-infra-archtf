/**
 * # E2E Hybrid Cloud Connectivity (HA VPN)
 *
 * This example demonstrates a Site-to-Site HA VPN configuration between two VPCs (Cloud and Simulated On-Prem).
 * It uses the `net-vpn` and `net-router` modules to establish secure connectivity with BGP dynamic routing.
 */

# 1. Network Infrastructure
module "vpc_cloud" {
  source = "../../modules/net-vpc"

  networks = {
    cloud-vpc = {
      name    = var.network_cloud_name
      project = var.project_id
    }
  }

  subnetworks = {
    cloud-subnet = {
      name          = "cloud-subnet"
      network       = "cloud-vpc" # Key to the networks map
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
      project       = var.project_id
    }
  }

  compute_routes = {}
}

module "vpc_onprem" {
  source = "../../modules/net-vpc"

  networks = {
    onprem-vpc = {
      name    = var.network_onprem_name
      project = var.project_id
    }
  }

  subnetworks = {
    onprem-subnet = {
      name          = "onprem-subnet"
      network       = "onprem-vpc" # Key to the networks map
      ip_cidr_range = "192.168.1.0/24"
      region        = var.region
      project       = var.project_id
    }
  }

  compute_routes = {}
}

# 2. Cloud Router - Cloud Side
module "router_cloud" {
  source = "../../modules/net-router"

  compute_routers = {
    router-cloud = {
      name    = "router-cloud"
      network = module.vpc_cloud.networks["cloud-vpc"].self_link
      region  = var.region
      project = var.project_id
      bgp = {
        asn = 64514
      }
    }
  }
}

# 3. Cloud Router - On-Prem Side
module "router_onprem" {
  source = "../../modules/net-router"

  compute_routers = {
    router-onprem = {
      name    = "router-onprem"
      network = module.vpc_onprem.networks["onprem-vpc"].self_link
      region  = var.region
      project = var.project_id
      bgp = {
        asn = 64515
      }
    }
  }
}

# 4. HA VPN - Cloud Side
module "vpn_cloud" {
  source = "../../modules/net-vpn"

  compute_ha_vpn_gateways = {
    vpn-cloud = {
      name    = "vpn-cloud"
      network = module.vpc_cloud.networks["cloud-vpc"].self_link
      region  = var.region
      project = var.project_id
      vpn_interfaces = [
        { id = 0 },
        { id = 1 }
      ]
    }
  }

  compute_vpn_tunnels = {
    tunnel-0 = {
      name                  = "tunnel-cloud-0"
      region                = var.region
      project               = var.project_id
      vpn_gateway           = "vpn-cloud"
      vpn_gateway_interface = 0
      peer_gcp_gateway      = module.vpn_onprem.ha_vpn_gateways["vpn-onprem"].self_link
      router                = module.router_cloud.routers["router-cloud"].name
      shared_secret         = "secret123"
    }
    tunnel-1 = {
      name                  = "tunnel-cloud-1"
      region                = var.region
      project               = var.project_id
      vpn_gateway           = "vpn-cloud"
      vpn_gateway_interface = 1
      peer_gcp_gateway      = module.vpn_onprem.ha_vpn_gateways["vpn-onprem"].self_link
      router                = module.router_cloud.routers["router-cloud"].name
      shared_secret         = "secret123"
    }
  }

  default_labels = var.default_labels
}

# 5. HA VPN - On-Prem Side
module "vpn_onprem" {
  source = "../../modules/net-vpn"

  compute_ha_vpn_gateways = {
    vpn-onprem = {
      name    = "vpn-onprem"
      network = module.vpc_onprem.networks["onprem-vpc"].self_link
      region  = var.region
      project = var.project_id
      vpn_interfaces = [
        { id = 0 },
        { id = 1 }
      ]
    }
  }

  compute_vpn_tunnels = {
    tunnel-0 = {
      name                  = "tunnel-onprem-0"
      region                = var.region
      project               = var.project_id
      vpn_gateway           = "vpn-onprem"
      vpn_gateway_interface = 0
      peer_gcp_gateway      = module.vpn_cloud.ha_vpn_gateways["vpn-cloud"].self_link
      router                = module.router_onprem.routers["router-onprem"].name
      shared_secret         = "secret123"
    }
    tunnel-1 = {
      name                  = "tunnel-onprem-1"
      region                = var.region
      project               = var.project_id
      vpn_gateway           = "vpn-onprem"
      vpn_gateway_interface = 1
      peer_gcp_gateway      = module.vpn_cloud.ha_vpn_gateways["vpn-cloud"].self_link
      router                = module.router_onprem.routers["router-onprem"].name
      shared_secret         = "secret123"
    }
  }

  default_labels = var.default_labels
}

# 6. BGP Configuration (Simulated)
# Note: In a real scenario, you'd add google_compute_router_interface and google_compute_router_peer
# using the net-router module outputs/inputs or via a separate BGP module.
# For simplicity in this E2E template, we focus on the gateway/tunnel established pattern.
