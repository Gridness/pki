output "vault_pki_root_path" {
  description = "Path to root PKI secrets engine"
  value       = vault_mount.pki_root.path
}

output "vault_pki_intermediate_path" {
  description = "Path to intermediate PKI secrets engine"
  value       = vault_mount.pki_intermediate.path
}

output "root_ca_certificate" {
  description = "Root CA certificate"
  value       = vault_pki_secret_backend_root_cert.root_ca.certificate
  sensitive   = true
}

output "intermediate_ca_certificate" {
  description = "Intermediate CA certificate"
  value       = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
  sensitive   = true
}

output "ca_certificate_chain" {
  description = "Full CA certificate chain"
  value       = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${vault_pki_secret_backend_root_cert.root_ca.certificate}"
  sensitive   = true
}

output "kubernetes_auth_path" {
  description = "Path to Kubernetes auth method"
  value       = vault_auth_backend.kubernetes.path
}

output "cert_manager_role_name" {
  description = "Vault role name for cert-manager"
  value       = vault_pki_secret_backend_role.cert_manager_role.name
}

output "vault_ready" {
  description = "Vault deployment is ready"
  value       = helm_release.vault.status
}
