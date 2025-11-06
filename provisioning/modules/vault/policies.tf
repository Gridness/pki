resource "vault_policy" "cert_manager" {
  name = "cert-manager"

  policy = <<EOT
path "pki_int/sign/cert-manager" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/cert-manager" {
  capabilities = ["create", "update"]
}

path "pki_int/cert/ca" {
  capabilities = ["read"]
}

path "pki_int/cert/ca_chain" {
  capabilities = ["read"]
}

path "pki_int/config/urls" {
  capabilities = ["read"]
}

path "pki_int/crl" {
  capabilities = ["read"]
}
EOT
}

resource "vault_policy" "istio_workload" {
  name = "istio-workload"

  policy = <<EOT
path "pki_int/sign/istio-workload" {
  capabilities = ["create", "update"]
}

path "pki_int/issue/istio-workload" {
  capabilities = ["create", "update"]
}

path "pki_int/cert/ca" {
  capabilities = ["read"]
}

path "pki_int/cert/ca_chain" {
  capabilities = ["read"]
}
EOT
}
