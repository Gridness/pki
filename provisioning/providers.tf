provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "vault" {
  address = var.vault_address
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
