output "buckets" {
  description = "Map of created bucket resources."
  value = {
    for k, v in google_storage_bucket.storage_buckets :
    k => v
  }
}

output "finops_labels" {
  description = "FinOps label package for this module (module + default_labels var), to be merged with workspace-level defaults."
  value       = local.bucket_labels_default
}

output "names" {
  description = "Map of bucket names."
  value = {
    for k, v in google_storage_bucket.storage_buckets :
    k => v.name
  }
}

output "objects" {
  description = "Map of created objects."
  value = {
    for k, v in google_storage_bucket_object.objects :
    k => {
      name          = v.name
      bucket        = v.bucket
      storage_class = v.storage_class
    }
  }
}

output "urls" {
  description = "Map of bucket URLs."
  value = {
    for k, v in google_storage_bucket.storage_buckets :
    k => v.url
  }
}
