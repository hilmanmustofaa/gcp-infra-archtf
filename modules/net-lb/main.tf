locals {
  # ===== FinOps labels. =====
  finops_labels_default = {
    gcp_asset_type = "compute.googleapis.com/BackendService"
    gcp_service    = "compute.googleapis.com"
    tf_module      = "net-lb"
    tf_layer       = "networking"
    tf_resource    = "load-balancer"
  }
}
