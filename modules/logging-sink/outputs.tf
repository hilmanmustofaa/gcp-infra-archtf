output "sink_ids" {
  description = "Map of logical key => log sink id."
  value = {
    for k, v in google_logging_project_sink.sinks : k => v.id
  }
}

output "sink_destinations" {
  description = "Map of logical key => fully-qualified sink destination URI."
  value       = local.sink_destinations
}

output "writer_identities" {
  description = "Map of logical key => sink writer identity (service account) to grant on the destination."
  value = {
    for k, v in google_logging_project_sink.sinks : k => v.writer_identity
  }
}
