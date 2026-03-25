/**
 * # Landing Zone - Layer 03: Workload Spoke
 *
 * This layer demonstrates deploying a Spoke project and connecting it 
 * to the Shared VPC Hub.
 */

# 1. Spoke Project
resource "google_project" "spoke_project" {
  name            = "app-spoke-prod"
  project_id      = "app-spoke-${formatdate("YYYYMMDD", timestamp())}"
  folder_id       = var.folder_id
  billing_account = var.billing_account
  labels          = var.default_labels
}

# 2. Service Project Attachment
resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = var.host_project_id
  service_project = google_project.spoke_project.project_id
}

# 3. Workload Example (GKE)
# In a real scenario, we would refer to the gke-cluster module here.
# For this composite example, we show the project-level integration.

output "spoke_project_id" {
  value = google_project.spoke_project.project_id
}
