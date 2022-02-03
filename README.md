# Kubernetes NGINX ingress Module

## Introduction

This module will install an NGINX ingress module into an AKS cluster.
<br />

## Usage

```bash
provider "helm" {
  alias = "aks"
  debug = true
  kubernetes {
    host                   = module.aks.kube_config.host
    username               = module.aks.kube_config.username
    password               = module.aks.kube_config.password
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}

module "ssh_key" {
  source = "git::https://github.com/danielscholl-terraform/module-ssh-key?ref=v1.0.0"
}

module "resource_group" {
  source = "git::https://github.com/danielscholl-terraform/module-resource-group?ref=v1.0.0"

  name     = "iac-terraform"
  location = "eastus2"

  resource_tags = {
    iac = "terraform"
  }
}

module "aks" {
  source     = "git::https://github.com/danielscholl-terraform/module-aks?ref=v1.0.0"
  depends_on = [module.resource_group, module.ssh_key]

  name                = format("iac-terraform-cluster-%s", module.resource_group.random)
  resource_group_name = module.resource_group.name
  dns_prefix          = format("iac-terraform-cluster-%s", module.resource_group.random)

  linux_profile = {
    admin_username = "k8sadmin"
    ssh_key        = "${trimspace(module.ssh_key.public_ssh_key)} k8sadmin"
  }

  default_node_pool = "default"
  node_pools = {
    default = {
      vm_size                = "Standard_B2s"
      enable_host_encryption = true

      node_count = 2
    }
  }

  resource_tags = {
    iac = "terraform"
  }
}

## Create a Static IP Address
resource "azurerm_public_ip" "main" {
  name                = format("%s-ingress-ip", module.resource_group.name)
  resource_group_name = module.aks.node_resource_group
  location            = module.resource_group.location
  allocation_method   = "Static"

  sku               = "Standard"

  tags = {
    iac = "terraform"
  }
}

## Deploy NGINX Ingress with Static IP Address
module "nginx" {
  source = "git::https://github.com/danielscholl-terraform/module-nginx-ingress?ref=v1.0.0"
  depends_on = [module.aks]

  providers = { helm = helm.aks }

  name                        = "ingress-nginx"
  namespace                   = "nginx-system"
  kubernetes_create_namespace = true

  load_balancer_ip = azurerm_public_ip.main.ip_address
  dns_label        = format("sample-%s", module.resource_group.random)
}
```

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | >=2.4.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| autoscaling | Enable autoscaling for the Ingress controller. | `bool` | `true` | no |
| autoscaling\_max\_replicas | Minimum number of replicas for the Ingress controller. | `number` | `11` | no |
| autoscaling\_min\_replicas | Minimum number of replicas for the Ingress controller. | `number` | `3` | no |
| chart\_version | HELM Chart Version for nginx controller | `string` | `"4.0.6"` | no |
| dns\_label | DNS label for building the FQDN of the Ingress controller. | `string` | `"iac-terraform"` | no |
| enable\_default\_tls | enable default tls (requires tls\_default\_secret) | `string` | `"false"` | no |
| ingress\_class | name of the ingress class to route through this controller | `string` | `"nginx"` | no |
| ingress\_type | Internal or Public. | `string` | `"Public"` | no |
| kubernetes\_create\_namespace | create kubernetes namespace | `bool` | `false` | no |
| load\_balancer\_ip | loadBalancerIP | `string` | n/a | yes |
| name | Name of helm release | `string` | `"ingress-nginx"` | no |
| namespace | Name of namespace where nginx controller should be deployed | `string` | `"kube-system"` | no |
| replica\_count | The number of replicas of the Ingress controller deployment. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| ingress\_class | Name of the ingress class to route through this controller |
<!--- END_TF_DOCS --->
