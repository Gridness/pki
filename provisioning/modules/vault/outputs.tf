output "vault_address" {
  description = "Vault service address"
  value       = "http://vault.${var.namespace}.svc.cluster.local:8200"
}

output "vault_token" {
  description = "Vault root token"
  value       = helm_release.vault.values[0].root_token
  sensitive   = true
}

output "namespace" {
  description = "Vault namespace"
  value       = var.namespace
}

output "pki_intermediate_path" {
  description = "Path to intermediate PKI for cert-manager"
  value       = "pki_int"
}

output "kubernetes_auth_path" {
  description = "Path to Kubernetes auth method"
  value       = "kubernetes"
}

output "cert_manager_role_name" {
  description = "Vault role name for cert-manager"
  value       = "cert-manager"
}
