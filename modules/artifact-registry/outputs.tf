output "finops_labels" {
  description = "FinOps label package for this module (module + labels var), to be merged with workspace-level defaults."
  value       = local.repository_labels
}

output "format" {
  description = "The repository format."
  value       = google_artifact_registry_repository.this.format
}

output "labels" {
  description = "Effective labels applied to the repository."
  value       = google_artifact_registry_repository.this.labels
}

output "location" {
  description = "Repository location (region or multi-region)."
  value       = google_artifact_registry_repository.this.location
}

output "name" {
  description = "Full resource name of the repository (projects/PROJECT/locations/LOC/repositories/REPO_ID)."
  value       = google_artifact_registry_repository.this.name
}

output "project_id" {
  description = "Project ID where the repository is created."
  value       = google_artifact_registry_repository.this.project
}

output "repository_id" {
  description = "The repository ID (last segment of the Artifact Registry repository name)."
  value       = google_artifact_registry_repository.this.repository_id
}

output "repository_url" {
  description = "Convenience URL/host form (for example: asia-southeast2-docker.pkg.dev/my-project/my-repo)."
  value       = local.repository_url
}
