variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "vault_namespace" {
  type    = string
  default = "vault"
}

variable "istio_namespace" {
  type    = string
  default = "istio-system"
}

variable "cert_manager_namespace" {
  type    = string
  default = "cert-manager"
}

variable "demo_namepsace" {
  type    = string
  default = "demo-services"
}

variable "issuer_email" {
  description = "Email for Let's Encrypt issuer"
  type        = string
}
