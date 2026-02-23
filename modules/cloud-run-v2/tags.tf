resource "google_tags_location_tag_binding" "binding" {
  for_each = var.create_job ? {} : var.tag_bindings
  parent = (
    "//run.googleapis.com/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_v2_service.service[0].name}"
  )
  tag_value = each.value
  location  = var.region
}
