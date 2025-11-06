locals {
  kubeconfig = yamldecode(file("${var.kubeconfig_path}"))
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = local.kubeconfig.clusters[0].cluster.server
  kubernetes_ca_cert = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)
}

resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_max_ttl                    = 3600
  token_policies                   = [vault_policy.cert_manager.name]
}
