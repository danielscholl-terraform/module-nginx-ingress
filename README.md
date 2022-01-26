# Kubernetes NGINX ingress Module

## Introduction

This module will install an NGINX ingress module into an AKS cluster.  This is largely to bridge the gap between AzureDNS/Azure Static IP/AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | >=2.4.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| chart\_version | HELM Chart Version for nginx controller | `string` | `"4.0.6"` | no |
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