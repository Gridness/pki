resource "helm_release" "istio" {
  name             = "istio"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = var.istio_version
  namespace        = var.namespace
  wait             = true
  create_namespace = true

  values = [
    yamlencode({
      service = {
        type = var.service_type
        nodePorts = var.service_type == "NodePort" ? {
          http  = var.nodeport_http
          https = var.nodeport_https
        } : {}
        loadBalancerIP = var.service_type == "LoadBalancer" ? var.load_balancer_ip : null
        externalName   = var.service_type == "ExternalName" ? var.external_name : null

        annotations = var.service_annotations
      }

      autoscaling = {
        enabled = false
      }

      podSecurityContext = {
        fsGroup      = 1337
        runAsGroup   = 1337
        runAsNonRoot = true
        runAsUser    = 1337
      }

      securityContext = {
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
        privileged             = false
        readOnlyRootFilesystem = true
      }

      resources = {
        requests = {
          cpu    = var.resources_requests_cpu
          memory = var.resources_requests_memory
        }
        limits = {
          cpu    = var.resources_limits_cpu
          memory = var.resources_limits_memory
        }
      }

      nodeSelector = var.node_selector

      tolerations = var.tolerations
    })
  ]
}

resource "kubernetes_manifest" "istio_gateway" {
  count = var.create_gateway_resource ? 1 : 0

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "${var.gateway_name}-gateway"
      namespace = var.namespace
    }
    spec = {
      selector = {
        istio = "gateway"
      }
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = var.gateway_hosts
          tls = var.redirect_to_https ? {
            httpsRedirect = true
          } : null
        },
        {
          port = {
            number   = 443
            name     = "https"
            protocol = "HTTPS"
          }
          hosts = var.gateway_hosts
          tls = {
            mode           = "MUTUAL"
            credentialName = var.tls_credential_name
          }
        }
      ]
    }
  }

  depends_on = [helm_release.istio_gateway]
}
