resource "google_tags_location_tag_binding" "binding" {
  for_each = var.tag_bindings
  parent = (
    "//run.googleapis.com/projects/${var.project_id}/locations/europe-west1/services/${google_cloud_run_service.service.name}"
  )
  tag_value = each.value
  location  = var.region
}
