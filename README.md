# tf-azure

## Resources

- Three peered VNets (one hub and two spokes)
- A load balancer in the hub VNet
- Two Linux VMs in the hub VNet private subnet
- A load balancer backend pool with the two Linux VMs
- Bastion host in the hub VNet
- A single VM in the spoke01 VNet (Reachable via the bastion host in the hub VNet)

## References

### Transit VNet using VNet Peering

https://azure.microsoft.com/en-us/blog/create-a-transit-vnet-using-vnet-peering/

https://www.paloaltonetworks.com/resources/guides/azure-transit-vnet-deployment-guide-common-firewall-option

### Quickstart load balancer

https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-portal

### Network security groups

https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.105.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_spoke01_vnet"></a> [spoke01\_vnet](#module\_spoke01\_vnet) | /Users/dan/github/dnlloyd/tf-azure-vnet | n/a |
| <a name="module_transit_vnet"></a> [transit\_vnet](#module\_transit\_vnet) | /Users/dan/github/dnlloyd/tf-azure-vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.spoke01_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.transit_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.spoke01_private_inbound_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.transit_private_inbound_allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.bu_tf_testing_spoke_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.bu_tf_testing_transit_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet_network_security_group_association.spoke01_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.transit_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network_peering.spoke_01_to_transit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.transit_to_spoke_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->