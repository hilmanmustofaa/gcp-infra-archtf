module "net-vpc" {
  source     = "../../net-vpc"
  project_id = "test-project"
  name       = "vpc-basic"
  subnets = [
    {
      name          = "subnet-1"
      region        = "us-central1"
      ip_cidr_range = "10.0.0.0/24"
    }
  ]
}

module "net-router" {
  source     = "../../net-router"
  project_id = "test-project"
  name       = "router-basic"
  region     = "us-central1"
  network    = module.net-vpc.network.self_link
}

module "net-cloudnat" {
  source = "../../"

  resource_prefix = "test"

  router_lookup = {
    router-basic = module.net-router.router
  }

  network_lookup = {
    subnet-1 = module.net-vpc.subnets["us-central1/subnet-1"]
  }

  nat_ip_lookup = {}

  compute_router_nats = {
    nat-basic = {
      name    = "nat-basic"
      project = "test-project"
      region  = "us-central1"
      router  = "router-basic"

      nat_ip_allocate_option             = "AUTO_ONLY"
      nat_ips                            = []
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

      log_config = {
        enable = true
        filter = "ERRORS_ONLY"
      }
    }
  }
}
