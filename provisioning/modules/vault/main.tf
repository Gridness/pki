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

resource "null_resource" "unseal_vault" {
  provisioner "local-exec" {
    command = "bash ${path.module}/init-vault.sh"
    environment = {
      VAULT_ADDR = var.vault_address
    }
  }

  depends_on = [helm_release.vault]
}
