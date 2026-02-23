output "id" {
  description = "Fully qualified firewall policy id."
  value = (
    local.use_hierarchical
    ? google_compute_firewall_policy.hierarchical[0].id
    : (
      local.use_regional
      ? google_compute_region_network_firewall_policy.net-regional[0].id
      : google_compute_network_firewall_policy.net-global[0].id
    )
  )
}
