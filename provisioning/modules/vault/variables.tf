variable "namespace" {
  description = "Vault namespace"
  type        = string
  default     = "vault"
}

variable "kubeconfig_path" {
  description = "Path of Kubernetes cluster kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "vault_chart_version" {
  description = "Vault helm chart version"
  type        = string
  default     = "0.31.0"
}

variable "vault_address" {
  description = "Vault server address"
  type        = string
  default     = "https://vault.vault.svc.cluster.local:8200"
}

variable "root_ca_common_name" {
  description = "Common name for root CA"
  type        = string
  default     = "PKI Root CA"
}

variable "intermediate_ca_common_name" {
  description = "Common name for intermediate CA"
  type        = string
  default     = "PKI Intermediate CA"
}

variable "ca_country" {
  description = "Country for CA certificates"
  type        = string
  default     = "US"
}

variable "ca_locality" {
  description = "Locality for CA certificates"
  type        = string
  default     = "Cupertino"
}

variable "ca_organization" {
  description = "Organization for CA certificates"
  type        = string
  default     = "Example Corp"
}

variable "allowed_domains" {
  description = "Allowed domains for certificate issuance"
  type        = list(string)
  default = [
    "example.com",
    "*.example.com",
    "cluster.local",
    "*.cluster.local",
    "svc.cluster.local",
    "*.svc.cluster.local"
  ]
}
