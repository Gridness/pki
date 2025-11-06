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

variable "service_type" {
  description = "Kubernetes service type for the ingress gateway"
  type        = string
  default     = "LoadBalancer"
  validation {
    condition     = contains(["NodePort", "LoadBalancer", "ClusterIP", "ExternalName"], var.service_type)
    error_message = "Service must be one of: NodePort, LoadBalancer, ClusterIP, ExternalName"
  }
}

variable "create_gateway_resouce" {
  description = "Enables the creation of istio gateway"
  type        = bool
  default     = true
}

variable "gateway_name" {
  description = "Name of istio gateway resource"
  type        = string
  default     = "core"
}

variable "gateway_hosts" {
  description = "istio gateway hosts"
  type        = list(any)
}

variable "redirect_to_https" {
  description = "Makes istio gateway redirect http traffic to https"
  type        = bool
  default     = true
}

variable "nodeport_http" {
  description = "NodePort for HTTP traffic (only used when service_type is NodePort)"
  type        = number
  default     = 30080
}

variable "nodeport_https" {
  description = "NodePort for HTTPS traffic (only used when service_type is NodePort)"
  type        = number
  default     = 30443
}

variable "load_balancer_ip" {
  description = "Static IP for LoadBalancer (optional)"
  type        = string
  default     = null
}

variable "external_name" {
  description = "External name for ExternalName service type (optional)"
  type        = string
  default     = null
}

variable "service_annotations" {
  description = "Annotations for the ingress gateway service"
  type        = map(string)
  default     = {}
}

variable "resources_requests_cpu" {
  description = "CPU requests for gateway pods"
  type        = string
  default     = "100m"
}

variable "resources_requests_memory" {
  description = "Memory requests for gateway pods"
  type        = string
  default     = "128Mi"
}

variable "resources_limits_cpu" {
  description = "CPU limits for gateway pods"
  type        = string
  default     = "2000m"
}

variable "resources_limits_memory" {
  description = "Memory limits for gateway pods"
  type        = string
  default     = "1024Mi"
}

variable "node_selector" {
  description = "Node selector for gateway pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for gateway pods"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "tls_credential_name" {
  description = "Name of the TLS credential secret"
  type        = string
  default     = "gateway-certs"
}
