resource "helm_release" "cert_manager" {
  name = "cert-manager"
  repository = "oci://quay.io/jetstack/charts/cert-manager"
  chart = "cert-manager"
  namespace = vars.cert_manager_namespace
  create_namespace = true
  wait = true
  max_history = 5
}
