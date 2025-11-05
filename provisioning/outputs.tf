output "vault_address" {
  value = module.vault.vault_address
}

output "istio_ingress_ip" {
  value = module.istio.ingress_ip
}

output "certificates_ready" {
  value = module.cert_manager.issuers_created
}
