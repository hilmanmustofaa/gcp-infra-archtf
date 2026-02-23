output "external_vpn_gateways" {
  description = "The created external VPN gateways."
  value       = google_compute_external_vpn_gateway.compute_external_vpn_gateways
}

output "ha_vpn_gateways" {
  description = "The created HA VPN gateways."
  value       = google_compute_ha_vpn_gateway.compute_ha_vpn_gateways
}

output "vpn_tunnels" {
  description = "The created VPN tunnels."
  value       = google_compute_vpn_tunnel.compute_vpn_tunnels
  sensitive   = true
}
