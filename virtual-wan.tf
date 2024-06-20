resource "azurerm_virtual_wan" "this" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name
  location            = azurerm_resource_group.bu_transit_network.location

  name                = "bu-vwan"
}

resource "azurerm_virtual_hub" "this" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name
  location            = azurerm_resource_group.bu_transit_network.location

  name                = "bu-vhub"
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_prefix      = local.virtual_hub_address_space
}

resource "azurerm_virtual_hub_connection" "this" {
  name                      = "bu-vhub-connection"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = module.transit_vnet.vnet_id
}
