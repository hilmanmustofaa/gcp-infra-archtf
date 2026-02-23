output "external_addresses" {
  description = "Allocated external addresses."
  value = {
    for address in google_compute_address.compute_addresses :
    address.name => address
  }
}

output "global_addresses" {
  description = "Allocated global external addresses."
  value = {
    for address in google_compute_global_address.global_addresses :
    address.name => address
  }
}

output "internal_addresses" {
  description = "Allocated internal addresses."
  value = {
    for address in google_compute_address.internal_addresses :
    address.name => address
  }
}

output "ipsec_interconnect_addresses" {
  description = "Allocated internal addresses for HPA VPN over Cloud Interconnect."
  value = {
    for address in google_compute_address.ipsec_interconnect_addresses :
    address.name => address
  }
}

output "psa_addresses" {
  description = "Allocated internal addresses for PSA endpoints."
  value = {
    for address in google_compute_global_address.psa_addresses :
    address.name => address
  }
}

