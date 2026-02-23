output "nat_ids" {
  description = "Map of NAT IDs keyed by name."
  value = {
    for k, v in google_compute_router_nat.compute_router_nats : k => v.id
  }
}

output "nat_names" {
  description = "Map of NAT names keyed by name."
  value = {
    for k, v in google_compute_router_nat.compute_router_nats : k => v.name
  }
}
