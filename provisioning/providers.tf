provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "vault" {
  address = var.vault_addr
}

provider "rng" {}
