resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = var.vault_chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  max_history      = 5

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault-auth"
    namespace = var.namespace
  }

  depends_on = [helm_release.vault]
}

resource "kubernetes_cluster_role_binding" "vault_auth" {
  metadata {
    name = "vault-auth-delegator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = var.namespace
  }

  depends_on = [kubernetes_service_account.vault]
}

data "kubernetes_secret" "vault_sa_token" {
  metadata {
    name      = kubernetes_service_account.vault.default_secret_name
    namespace = var.namespace
  }

  depends_on = [kubernetes_service_account.vault]
}

data "kubernetes_service" "kubernetes_api" {
  metadata {
    name      = "kubernetes"
    namespace = "default"
  }
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "<https://${data.kubernetes_service.kubernetes_api.status > [0].load_balancer[0].ingress[0].ip}:443"
  kubernetes_ca_cert     = data.kubernetes_secret.vault_sa_token.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault_sa_token.data["token"]
  disable_iss_validation = true

  depends_on = [vault_auth_backend.kubernetes]
}

resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  policies                         = [vault_policy.pki.name]
  ttl                              = "20m"

  depends_on = [vault_kubernetes_auth_backend_config.kubernetes]
}

resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "PKI for the ROOT CA"
  default_lease_ttl_seconds = 86400     # 1 day
  max_lease_ttl_seconds     = 315360000 # 10 years
}

resource "vault_mount" "pki_int" {
  path                      = "pki_int"
  type                      = "pki"
  description               = "PKI for Intermediate CA"
  default_lease_ttl_seconds = 86400     # 1 day
  max_lease_ttl_seconds     = 157680000 # 5 years
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend            = vault_mount.pki.path
  type               = "internal"
  common_name        = "Root CA"
  ttl                = "315360000" # 10 years
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = 4096
  issuer_name        = "root-2025"
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["${var.vault_addr}/v1/pki/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/pki/crl"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend            = vault_mount.pki_int.path
  type               = "internal"
  common_name        = "Intermediate CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = 4096
}

resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  backend     = vault_mount.pki.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = "Intermediate CA"
  ttl         = 157680000 # 5 years
  format      = "pem_bundle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.root.certificate}\n${vault_pki_secret_backend_root_cert.root.certificate}"
}

resource "vault_pki_secret_backend_role" "server" {
  backend          = vault_mount.pki_int.path
  name             = "server-role"
  ttl              = 2592000 # 30 days
  max_ttl          = 2592000 # 30 days
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com"]
  allow_subdomains = true
}

resource "vault_policy" "pki" {
  name = "pki"

  policy = <<EOT
path "pki_int/sign/server-role" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/server-role" {
  capabilities = ["create"]
}

path "pki_int/certs" {
  capabilities = ["list"]
}

path "pki_int/certs/*" {
  capabilities = ["read"]
}

path "pki_int" {
  capabilities = ["list"]
}
EOT
}
