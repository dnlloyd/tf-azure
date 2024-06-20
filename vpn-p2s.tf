resource "azurerm_vpn_server_configuration" "this" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name
  location            = azurerm_resource_group.bu_transit_network.location

  name                     = "p2s-vpn-server-config"
  vpn_authentication_types = ["AAD"]
  vpn_protocols            = ["OpenVPN"]

  azure_active_directory_authentication {
    audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    issuer   = "https://sts.windows.net/${local.tenant_id}/"
    tenant   = "https://login.microsoftonline.com/${local.tenant_id}"
  }
}

resource "azurerm_point_to_site_vpn_gateway" "this" {
  resource_group_name = azurerm_resource_group.bu_transit_network.name
  location            = azurerm_resource_group.bu_transit_network.location

  name                        = "bu-p2s-vpn-gw"
  virtual_hub_id              = azurerm_virtual_hub.this.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.this.id
  scale_unit                  = 1
  
  connection_configuration {
    name = "bu-p2s-vpn-gw-connection"

    vpn_client_address_pool {
      address_prefixes = local.vpn_prefixes
    }
  }
}
