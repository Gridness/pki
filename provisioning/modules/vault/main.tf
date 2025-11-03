resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "PKI for the ROOT CA"
  default_lease_ttl_seconds = 86400      # 1 day
  max_lease_ttl_seconds     = 315360000  # 10 years
}

resource "vault_mount" "pki_int" {
  path                      = "pki_int"
  type                      = "pki"
  description               = "PKI for Intermediate CA"
  default_lease_ttl_seconds = 86400      # 1 day
  max_lease_ttl_seconds     = 157680000  # 5 years
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = "315360000" # 10 years
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  issuer_name          = "root-2025"
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["${var.vault_addr}/v1/pki/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/pki/crl"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend             = vault_mount.pki_int.path
  type                = "internal"
  common_name         = "Intermediate CA"
  format              = "pem"
  private_key_format  = "der"
  key_type            = "rsa"
  key_bits            = 4096
}

resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  backend      = vault_mount.pki.path
  csr          = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name  = "Intermediate CA"
  ttl          = 157680000  # 5 years
  format       = "pem_bundle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.root.certificate}\n${vault_pki_secret_backend_root_cert.root.certificate}"
}

resource "vault_pki_secret_backend_role" "server" {
  backend          = vault_mount.pki_int.path
  name             = "server-role"
  ttl              = 2592000  # 30 days
  max_ttl          = 2592000  # 30 days
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com"]
  allow_subdomains = true
}
