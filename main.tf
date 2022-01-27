##############################################################
# This module allows the creation of an NGINX Ingress Controller
##############################################################

locals {
  helm_chart      = "ingress-nginx"
  helm_repository = "https://kubernetes.github.io/ingress-nginx"
}

resource "helm_release" "nginx" {
  name             = var.name
  chart            = local.helm_chart
  namespace        = var.namespace
  repository       = local.helm_repository
  version          = var.chart_version
  create_namespace = var.kubernetes_create_namespace

  values = [
    yamlencode({
      controller = {
        replicaCount = var.replica_count
        ingressClass = var.ingress_class
        publishService = {
          enabled      = true
          pathOverride = "${var.namespace}/${var.name}-controller"
        }
        config = {
          ssl-redirect = var.enable_default_tls
        }
        service = {
          loadBalancerIP = var.load_balancer_ip
          annotations = var.ingress_type == "Internal" ? {
            "service.beta.kubernetes.io/azure-load-balancer-internal" : "true"
          } : {
            "service.beta.kubernetes.io/azure-dns-label-name" : var.dns_label
          }
        }
      }
    }),
    var.additional_yaml_config
  ]
}

