output "firewall_rules" {
  description = "Created firewall rules."
  value       = google_compute_firewall.compute_firewalls
}

output "firewall_rules_self_links" {
  description = "Self links of created firewall rules."
  value = {
    for k, v in google_compute_firewall.compute_firewalls : k => v.self_link
  }
}