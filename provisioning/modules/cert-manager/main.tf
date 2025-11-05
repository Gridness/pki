resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts/cert-manager"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  create_namespace = true
  wait             = true
  max_history      = 5

  values = [
    file("${module.path}/values.yaml")
  ]
}
