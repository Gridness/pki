locals {
  vault_namespace = "vault"
  pki_path        = "pki"
  pki_int_path    = "pki_int"

  ca_ttl           = "87600h" # 10 years
  intermediate_ttl = "43800h" # 5 years
  leaf_ttl         = "720h"   # 30 days
}

resource "vault_mount" "pki_root" {
  path                      = local.pki_path
  type                      = "pki"
  description               = "Root PKI secrets engine"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  backend     = vault_mount.pki_root.path
  type        = "internal"
  common_name = var.root_ca_common_name
  ttl         = local.ca_ttl
  format      = "pem"
  key_type    = "rsa"
  key_bits    = 4096

  country      = var.ca_country
  locality     = var.ca_locality
  organization = var.ca_organization
  ou           = "Root CA"
}

resource "vault_pki_secret_backend_config_urls" "pki_root_urls" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["${var.vault_address}/v1/${local.pki_path}/ca"]
  crl_distribution_points = ["${var.vault_address}/v1/${local.pki_path}/crl"]
}

resource "vault_mount" "pki_intermediate" {
  path                      = local.pki_int_path
  type                      = "pki"
  description               = "Intermediate PKI secrets engine for cert-manager"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000 # 5 years
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  type        = "internal"
  common_name = var.intermediate_ca_common_name
  key_type    = "rsa"
  key_bits    = 4096

  country      = var.ca_country
  locality     = var.ca_locality
  organization = var.ca_organization
  ou           = "Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend     = vault_mount.pki_root.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = var.intermediate_ca_common_name
  ttl         = local.intermediate_ttl
  format      = "pem"

  exclude_cn_from_sans = true
  max_path_length      = 0
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "pki_intermediate_urls" {
  backend                 = vault_mount.pki_intermediate.path
  issuing_certificates    = ["${var.vault_address}/v1/${local.pki_int_path}/ca"]
  crl_distribution_points = ["${var.vault_address}/v1/${local.pki_int_path}/crl"]
}

resource "vault_pki_secret_backend_role" "cert_manager_role" {
  backend = vault_mount.pki_intermediate.path
  name    = "cert-manager"
  ttl     = local.leaf_ttl
  max_ttl = local.leaf_ttl

  allow_ip_sans      = true
  allow_localhost    = true
  allow_any_name     = true
  allow_bare_domains = true
  allow_subdomains   = true
  allow_glob_domains = true

  server_flag           = true
  client_flag           = true
  code_signing_flag     = false
  email_protection_flag = false

  key_type      = "rsa"
  key_bits      = 2048
  key_usage     = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  ext_key_usage = ["ServerAuth", "ClientAuth"]

  enforce_hostnames  = false
  require_cn         = false
  policy_identifiers = []

  allowed_domains          = var.allowed_domains
  allowed_domains_template = true
}

resource "vault_pki_secret_backend_role" "istio_workload_role" {
  backend = vault_mount.pki_intermediate.path
  name    = "istio-workload"
  ttl     = "24h"
  max_ttl = "24h"

  allow_ip_sans      = true
  allow_localhost    = true
  allow_any_name     = true
  allow_bare_domains = true
  allow_subdomains   = true

  server_flag = true
  client_flag = true

  key_type = "rsa"
  key_bits = 2048

  enforce_hostnames = false
  require_cn        = false

  allowed_domains          = var.allowed_domains
  allowed_domains_template = true
}
