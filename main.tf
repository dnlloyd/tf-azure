provider "azurerm" {
  features {}
}

locals {
  transit_vnet_address_space      = "10.0.0.0/16"
  transit_private_subnet_prefixes = ["10.0.0.0/24"]
  transit_public_subnet_prefixes  = ["10.0.3.0/24"]
  transit_bastion_subnet_prefixes = ["10.0.199.0/24"]

  spoke_01_vnet_address_space      = "10.1.0.0/16"
  spoke_01_private_subnet_prefixes = ["10.1.0.0/24"]

  spoke_02_vnet_address_space = "10.2.0.0/16"

  tags = {
    use       = "BU Terraform Testing"
    createdBy = "Terraform"
    owner     = "Daniel Lloyd"
  }
}
### Transit VNet ###
resource "azurerm_resource_group" "bu_tf_testing_transit_vnet" {
  name     = "bu-tf-testing-transit-vnet"
  location = "Central US"

  tags = local.tags
}

module "transit_vnet" {
  source = "github.com/dnlloyd/tf-azure-vnet"
  # source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  resource_group_location = azurerm_resource_group.bu_tf_testing_transit_vnet.location

  name                            = "BU-Transit"
  vnet_address_space              = local.transit_vnet_address_space
  public_subnet_prefixes          = local.transit_public_subnet_prefixes
  private_subnet_prefixes         = local.transit_private_subnet_prefixes
  transit_bastion_subnet_prefixes = local.transit_bastion_subnet_prefixes
  tags                            = local.tags
}

resource "azurerm_network_security_group" "transit_private" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name = "Private"
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "transit_private" {
  network_security_group_id = azurerm_network_security_group.transit_private.id
  subnet_id                 = module.transit_vnet.private_subnet_id
}

resource "azurerm_network_security_rule" "transit_private_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.transit_private.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = local.transit_private_subnet_prefixes[0]
}

### Spoke01 VNet ###
resource "azurerm_resource_group" "bu_tf_testing_spoke_vnet" {
  name     = "bu-tf-testing-spoke-vnet"
  location = "Central US"

  tags = local.tags
}

module "spoke01_vnet" {
  source = "github.com/dnlloyd/tf-azure-vnet"
  # source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_tf_testing_spoke_vnet.name
  resource_group_location = azurerm_resource_group.bu_tf_testing_spoke_vnet.location

  name                    = "BU-Spoke-01"
  vnet_address_space      = local.spoke_01_vnet_address_space
  private_subnet_prefixes = local.spoke_01_private_subnet_prefixes
  tags                    = local.tags
}

resource "azurerm_network_security_group" "spoke01_private" {
  location            = azurerm_resource_group.bu_tf_testing_spoke_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name = "Private"
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke01_private" {
  network_security_group_id = azurerm_network_security_group.spoke01_private.id
  subnet_id                 = module.spoke01_vnet.private_subnet_id
}

resource "azurerm_network_security_rule" "spoke01_private_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.spoke01_private.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = local.spoke_01_private_subnet_prefixes[0]
}

### Peering ###
resource "azurerm_virtual_network_peering" "transit_to_spoke_01" {
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name                      = "TransitToSpoke01"
  virtual_network_name      = module.transit_vnet.vnet_name
  remote_virtual_network_id = module.spoke01_vnet.vnet_id

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "spoke_01_to_transit" {
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name                      = "Spoke01ToTransit"
  virtual_network_name      = module.spoke01_vnet.vnet_name
  remote_virtual_network_id = module.transit_vnet.vnet_id

  allow_forwarded_traffic = true
}
