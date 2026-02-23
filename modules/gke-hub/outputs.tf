output "cluster_ids" {
  description = "Fully qualified ids of all clusters."
  value = {
    for k, v in google_gke_hub_membership.default : k => v.id
  }
  depends_on = [
    google_gke_hub_membership.default,
    google_gke_hub_feature.default,
    google_gke_hub_feature_membership.default,
  ]
}
