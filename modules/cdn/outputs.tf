output "backend_bucket_ids" {
  description = "Map of backend bucket IDs."
  value = {
    for k, v in google_compute_backend_bucket.cdn_backend_buckets : k => v.id
  }
}

output "backend_bucket_names" {
  description = "Map of backend bucket names."
  value = {
    for k, v in google_compute_backend_bucket.cdn_backend_buckets : k => v.name
  }
}

output "backend_bucket_self_links" {
  description = "Map of backend bucket self links."
  value = {
    for k, v in google_compute_backend_bucket.cdn_backend_buckets : k => v.self_link
  }
}

output "cdn_backend_buckets" {
  description = "The created CDN backend buckets."
  value       = google_compute_backend_bucket.cdn_backend_buckets
}
