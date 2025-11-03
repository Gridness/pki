```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Service Mesh"
            ServiceA[Service A<br/>with Envoy Sidecar]
            ServiceB[Service B<br/>with Envoy Sidecar]
        end
        
        subgraph "Certificate Management"
            istio_csr[istio-csr<br/>CSR Agent]
            cert_manager[cert-manager]
            vault_issuer[Vault Issuer]
        end
        
        subgraph "PKI Storage"
            vault[HashiCorp Vault<br/>PKI Engine]
            intermediate_ca[Intermediate CA<br/>Private Key]
        end
        
        subgraph "Service Mesh Control"
            istio[Istio Control Plane]
        end
    end
    
    ServiceA -->|1. CSR Request| istio_csr
    ServiceB -->|1. CSR Request| istio_csr
    istio_csr -->|2. Forward CSR| cert_manager
    cert_manager -->|3. Send CSR| vault_issuer
    vault_issuer -->|4. Request Signing| vault
    vault -->|5. Sign with| intermediate_ca
    intermediate_ca -->|6. Return Certificate| vault
    vault -->|7. Return Certificate| vault_issuer
    vault_issuer -->|8. Return Certificate| cert_manager
    cert_manager -->|9. Distribute Certificate| istio_csr
    istio_csr -->|10. Deliver Certificate| ServiceA
    istio_csr -->|10. Deliver Certificate| ServiceB
    ServiceA <-->|11. mTLS Communication| ServiceB
    
    istio -.->|Manages| ServiceA
    istio -.->|Manages| ServiceB
```

## Overview
This Kubernetes-native PKI implementation consists of the following components:
- HashiCorp Vault which implements PKI storage with root and intermediate CAs
- Cert-manager configured with VaultIssuer to use the Vault as the CA
- Istio which implements the service mesh within k8s cluster

## Explanation
When a service discovered within service mesh wants to communicate with another service alike, it must perform mTLS handshake. So it goes:

1. Service wants to establish connection to another service in the mesh
2. Istio-csr captures the CSR and forwards it to cert-manager
3. Cert-manager sends the CSR to Vault to sign certificates for mTLS handshake (since it is configured to use the vault)
4. Vault Issuer communicates with Vault and requests certificates signing using the Vault's intermediate CA private key
5. The Vault signs certificates and returns them back to service mesh
6. Services can now perform mTLS handshake
