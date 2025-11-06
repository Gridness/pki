output "gateway_name" {
  description = "Name of the deployed gateway"
  value       = helm_release.istio_gateway.name
}

output "gateway_namespace" {
  description = "Namespace of the gateway"
  value       = helm_release.istio_gateway.namespace
}

output "service_type" {
  description = "Service type of the gateway"
  value       = var.service_type
}

output "external_ip" {
  description = "External IP of the gateway service (for LoadBalancer type)"
  value       = var.service_type == "LoadBalancer" ? "Check kubectl get svc -n ${var.namespace}" : null
}

output "external_name" {
  description = "External Name of the gateway service (for ExternalName type)"
  value       = var.service_type == "ExternalName" ? "Check kubectl get svc -n ${var.namespace}" : null
}

output "nodeports" {
  description = "NodePorts for the gateway (for NodePort type)"
  value = var.service_type == "NodePort" ? {
    http  = var.nodeport_http
    https = var.nodeport_https
  } : null
}

output "gateway_ready" {
  description = "Gateway deployment is ready"
  value       = helm_release.istio_gateway.status
}
