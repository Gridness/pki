module "istio" {
  source = "./modules/istio"

  cluster_name = var.cluster_name
  namespace    = var.istio_namespace
}

module "vault" {
  source = "./modules/vault"

  cluster_name = var.cluster_name
  namespace    = var.vault_namespace

  depends_on = [module.istio]
}
