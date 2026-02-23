resource "tls_private_key" "private_keys" {
  for_each = var.tls_private_keys

  algorithm   = each.value.algorithm
  rsa_bits    = each.value.rsa_bits
  ecdsa_curve = each.value.ecdsa_curve
}
  