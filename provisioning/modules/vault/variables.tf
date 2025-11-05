variable "namespace" {
  description = "Kubernetes namespace for Vault"
  type        = string
  default     = "vault"
}

variable "vault_chart_version" {
  description = "Helm chart version for Vault"
  type        = string
  default     = "0.31.0"
}
