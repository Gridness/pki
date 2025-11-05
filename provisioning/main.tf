module "vault" {
  source = "./modules/vault"

  namespace    = var.vault_namespace
}

module "istio" {
  source = "./modules/istio"

  namespace     = var.istio_namespace
  vault_address = module.vault.vault_address
  vault_token   = module.vault.vault_token

  depends_on = [module.vault]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  namespace     = var.cert_manager_namespace
  vault_address = module.vault.vault_address

  depends_on = [module.istio]
}

module "demo_services" {
  source = "./modules/demo-services"

  namespace              = var.demo_namespace
  istio_namespace        = module.istio.namespace
  cert_manager_namespace = module.cert_manager.namespace

  depends_on = [module.cert_manager]
}
