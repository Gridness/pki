terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.3.0"
    }
    rng = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}
