##############################################################
# This module allows the creation of an NGINX Ingress Controller
##############################################################

output "ingress_class" {
  description = "Name of the ingress class to route through this controller"
  value       = var.ingress_class
}
