resource "helm_release" "sampleapp" {
  name  = (var.name != null ? var.name : "sampleapp")
  chart = "${path.module}/chart"

  namespace        = var.namespace
  create_namespace = var.kubernetes_create_namespace

  values = [<<-EOT

  EOT
  ]
}
