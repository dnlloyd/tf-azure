provider "azurerm" {
  features {}
}

locals {
  tenant_id = "6d63de4b-0ef7-4b38-bfe8-1d9d85c94dcd"

  transit_vnet_address_space        = "10.0.0.0/17"
  transit_private_subnet_prefixes   = ["10.0.0.0/22"]
  transit_public_subnet_prefixes    = ["10.0.4.0/22"]
  # transit_bastion_subnet_prefixes = ["10.0.255.0/24"]
  vpn_prefixes                      = ["10.0.127.0/24"]

  virtual_hub_address_space       = "10.0.128.0/17"

  spoke01_vnet_address_space      = "10.1.0.0/16"
  spoke01_private_subnet_prefixes = ["10.1.0.0/22"]
  spoke01_public_subnet_prefixes = ["10.1.4.0/22"]

  spoke02_vnet_address_space      = "10.2.0.0/16"
  spoke02_private_subnet_prefixes = ["10.2.0.0/22"]
  spoke02_public_subnet_prefixes = ["10.2.4.0/22"]

  spoke03_vnet_address_space      = "10.3.0.0/16"
  spoke03_private_subnet_prefixes = ["10.3.0.0/22"]
  spoke03_public_subnet_prefixes = ["10.3.4.0/22"]

  tags = {
    use       = "BU Terraform Testing"
    createdBy = "Terraform"
    owner     = "Daniel Lloyd"
  }
}

### Transit ###
resource "azurerm_resource_group" "bu_transit_network" {
  name     = "bu-transit-networking"
  location = "Central US"

  tags = local.tags
}

module "transit_vnet" {
  # source = "github.com/dnlloyd/tf-azure-vnet"
  source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_transit_network.name
  resource_group_location = azurerm_resource_group.bu_transit_network.location

  name                            = "BU-Transit-VNet"
  vnet_address_space              = local.transit_vnet_address_space
  public_subnet_prefixes          = local.transit_public_subnet_prefixes
  private_subnet_prefixes         = local.transit_private_subnet_prefixes
  # transit_bastion_subnet_prefixes = local.transit_bastion_subnet_prefixes
  tags                            = local.tags
}

# TODO: determine how this will be leveraged or else remove
# resource "azurerm_network_security_group" "transit_private" {
#   location            = azurerm_resource_group.bu_transit_network.location
#   resource_group_name = azurerm_resource_group.bu_transit_network.name

#   name = "Private"
#   tags = local.tags
# }

# resource "azurerm_subnet_network_security_group_association" "transit_private" {
#   network_security_group_id = azurerm_network_security_group.transit_private.id
#   subnet_id                 = module.transit_vnet.private_subnet_id
# }

# resource "azurerm_network_security_rule" "transit_private_inbound_allow_all" { # TODO: Refine
#   resource_group_name = azurerm_resource_group.bu_transit_network.name

#   name                        = "Inbound_Allow_Any_Any"
#   network_security_group_name = azurerm_network_security_group.transit_private.name

#   priority                   = 100
#   direction                  = "Inbound"
#   access                     = "Allow"
#   protocol                   = "*"
#   source_port_range          = "*"
#   destination_port_range     = "*"
#   source_address_prefix      = "*"
#   destination_address_prefix = local.transit_private_subnet_prefixes[0]
# }

### Spoke01 ###
resource "azurerm_resource_group" "bu_spoke01_network" {
  name     = "bu-spoke01-networking"
  location = "Central US"

  tags = local.tags
}

module "spoke01_vnet" {
  # source = "github.com/dnlloyd/tf-azure-vnet"
  source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_spoke01_network.name
  resource_group_location = azurerm_resource_group.bu_spoke01_network.location

  name                    = "BU-Spoke01-VNet"
  vnet_address_space      = local.spoke01_vnet_address_space
  public_subnet_prefixes  = local.spoke01_public_subnet_prefixes
  private_subnet_prefixes = local.spoke01_private_subnet_prefixes
  tags                    = local.tags
}

resource "azurerm_network_security_group" "spoke01_private" {
  location            = azurerm_resource_group.bu_spoke01_network.location
  resource_group_name = azurerm_resource_group.bu_spoke01_network.name

  name = "Private"
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke01_private" {
  network_security_group_id = azurerm_network_security_group.spoke01_private.id
  subnet_id                 = module.spoke01_vnet.private_subnet_id
}

resource "azurerm_network_security_rule" "spoke01_private_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_spoke01_network.name

  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.spoke01_private.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = local.spoke01_private_subnet_prefixes[0]
}

### Spoke02 ###
resource "azurerm_resource_group" "bu_spoke02_network" {
  name     = "bu-spoke02-networking"
  location = "Central US"

  tags = local.tags
}

module "spoke02_vnet" {
  # source = "github.com/dnlloyd/tf-azure-vnet"
  source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_spoke02_network.name
  resource_group_location = azurerm_resource_group.bu_spoke02_network.location

  name                    = "BU-Spoke02-VNet"
  vnet_address_space      = local.spoke02_vnet_address_space
  public_subnet_prefixes  = local.spoke02_public_subnet_prefixes
  private_subnet_prefixes = local.spoke02_private_subnet_prefixes
  tags                    = local.tags
}

resource "azurerm_network_security_group" "spoke02_private" {
  location            = azurerm_resource_group.bu_spoke02_network.location
  resource_group_name = azurerm_resource_group.bu_spoke02_network.name

  name = "Private"
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke02_private" {
  network_security_group_id = azurerm_network_security_group.spoke02_private.id
  subnet_id                 = module.spoke02_vnet.private_subnet_id
}

resource "azurerm_network_security_rule" "spoke02_private_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_spoke02_network.name

  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.spoke02_private.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = local.spoke02_private_subnet_prefixes[0]
}

### Spoke03 ###
resource "azurerm_resource_group" "bu_spoke03_network" {
  name     = "bu-spoke03-networking"
  location = "Central US"

  tags = local.tags
}

module "spoke03_vnet" {
  # source = "github.com/dnlloyd/tf-azure-vnet"
  source = "/Users/dan/github/dnlloyd/tf-azure-vnet"

  resource_group_name     = azurerm_resource_group.bu_spoke03_network.name
  resource_group_location = azurerm_resource_group.bu_spoke03_network.location

  name                    = "BU-Spoke03-VNet"
  vnet_address_space      = local.spoke03_vnet_address_space
  public_subnet_prefixes  = local.spoke03_public_subnet_prefixes
  private_subnet_prefixes = local.spoke03_private_subnet_prefixes
  tags                    = local.tags
}

resource "azurerm_network_security_group" "spoke03_private" {
  location            = azurerm_resource_group.bu_spoke03_network.location
  resource_group_name = azurerm_resource_group.bu_spoke03_network.name

  name = "Private"
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke03_private" {
  network_security_group_id = azurerm_network_security_group.spoke03_private.id
  subnet_id                 = module.spoke03_vnet.private_subnet_id
}

resource "azurerm_network_security_rule" "spoke03_private_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_spoke03_network.name

  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.spoke03_private.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = local.spoke03_private_subnet_prefixes[0]
}

### Peering ###
resource "azurerm_virtual_network_peering" "transit_to_spoke01" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name                      = "TransitToSpoke01"
  virtual_network_name      = module.transit_vnet.vnet_name
  remote_virtual_network_id = module.spoke01_vnet.vnet_id

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "spoke01_to_transit" {
  resource_group_name = azurerm_resource_group.bu_spoke01_network.name

  name                      = "Spoke01ToTransit"
  virtual_network_name      = module.spoke01_vnet.vnet_name
  remote_virtual_network_id = module.transit_vnet.vnet_id

  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "transit_to_spoke02" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name                      = "TransitToSpoke02"
  virtual_network_name      = module.transit_vnet.vnet_name
  remote_virtual_network_id = module.spoke02_vnet.vnet_id

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "spoke02_to_transit" {
  resource_group_name = azurerm_resource_group.bu_spoke02_network.name

  name                      = "Spoke02ToTransit"
  virtual_network_name      = module.spoke02_vnet.vnet_name
  remote_virtual_network_id = module.transit_vnet.vnet_id

  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "transit_to_spoke03" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name                      = "TransitToSpoke03"
  virtual_network_name      = module.transit_vnet.vnet_name
  remote_virtual_network_id = module.spoke03_vnet.vnet_id

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "spoke03_to_transit" {
  resource_group_name = azurerm_resource_group.bu_spoke03_network.name

  name                      = "Spoke03ToTransit"
  virtual_network_name      = module.spoke03_vnet.vnet_name
  remote_virtual_network_id = module.transit_vnet.vnet_id

  allow_forwarded_traffic = true
}
