variable "namespace" {
  description = "Kubernetes namespace for Istio"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_chart_version" {
  description = "Helm chart version for Istio"
  type        = string
  default     = "1.19.1"
}
