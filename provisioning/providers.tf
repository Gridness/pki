provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "vault" {
  address = var.vault_addr
  # todo: set token via env var
}

provider "rng" {}
