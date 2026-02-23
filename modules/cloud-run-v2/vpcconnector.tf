resource "google_vpc_access_connector" "connector" {
  count   = var.vpc_connector_create != null ? 1 : 0
  project = var.project_id
  name = (
    var.vpc_connector_create.name != null
    ? var.vpc_connector_create.name
    : var.name
  )
  region         = var.region
  ip_cidr_range  = var.vpc_connector_create.ip_cidr_range
  network        = var.vpc_connector_create.network
  machine_type   = var.vpc_connector_create.machine_type
  max_instances  = var.vpc_connector_create.instances.max
  max_throughput = var.vpc_connector_create.throughput.max
  min_instances  = var.vpc_connector_create.instances.min
  min_throughput = var.vpc_connector_create.throughput.min
  dynamic "subnet" {
    for_each = var.vpc_connector_create.subnet.name == null ? [] : [""]
    content {
      name       = var.vpc_connector_create.subnet.name
      project_id = var.vpc_connector_create.subnet.project_id
    }
  }
}

