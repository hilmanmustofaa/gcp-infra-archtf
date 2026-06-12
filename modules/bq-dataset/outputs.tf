output "dataset_ids" {
  description = "Map of logical key => BigQuery dataset_id."
  value = {
    for k, v in google_bigquery_dataset.datasets : k => v.dataset_id
  }
}

output "dataset_self_links" {
  description = "Map of logical key => dataset self_link."
  value = {
    for k, v in google_bigquery_dataset.datasets : k => v.self_link
  }
}

output "finops_labels" {
  description = "FinOps label package for this module, to be merged with workspace-level defaults."
  value       = local.finops_labels
}
