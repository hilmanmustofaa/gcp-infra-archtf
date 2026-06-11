locals {
  brand_name = var.create_brand ? google_iap_brand.brand[0].name : null
}

# ── IAP OAuth brand (singleton per project) ──────────────────────────────────
resource "google_iap_brand" "brand" {
  count = var.create_brand ? 1 : 0

  project           = var.project_id
  support_email     = var.brand.support_email
  application_title = var.brand.application_title
}

resource "google_iap_client" "client" {
  count = var.create_client ? 1 : 0

  display_name = var.oauth_client.display_name
  brand        = google_iap_brand.brand[0].name
}

# ── IAP tunnel instance IAM (SSH/RDP to VMs through IAP) ──────────────────────
resource "google_iap_tunnel_instance_iam_binding" "tunnel_bindings" {
  for_each = var.tunnel_instance_bindings

  project  = var.project_id
  zone     = each.value.zone
  instance = each.value.instance
  role     = each.value.role
  members  = each.value.members
}

resource "google_iap_tunnel_instance_iam_member" "tunnel_members" {
  for_each = var.tunnel_instance_members

  project  = var.project_id
  zone     = each.value.zone
  instance = each.value.instance
  role     = each.value.role
  member   = each.value.member
}

# ── IAP web backend service IAM (protect Cloud Run / GKE behind a LB) ─────────
resource "google_iap_web_backend_service_iam_binding" "web_backend_bindings" {
  for_each = var.web_backend_bindings

  project             = var.project_id
  web_backend_service = each.value.web_backend_service
  role                = each.value.role
  members             = each.value.members
}

resource "google_iap_web_backend_service_iam_member" "web_backend_members" {
  for_each = var.web_backend_members

  project             = var.project_id
  web_backend_service = each.value.web_backend_service
  role                = each.value.role
  member              = each.value.member
}
