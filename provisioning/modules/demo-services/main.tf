resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.namespace
    labels = {
      appgroup = "demo-services"
      servicemesh = "istio"
    }
  }
}
