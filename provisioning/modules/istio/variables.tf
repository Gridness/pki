variable "namespace" {
  description = "Kubernetes namespace for Istio"
  type        = string
  default     = "istio-system"
}

variable "istio_chart_version" {
  description = "Helm chart version for Istio"
  type        = string
  default     = "1.27.3"
}
