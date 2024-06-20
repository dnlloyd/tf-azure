resource "azurerm_public_ip" "transit_lb" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name              = "PublicIPForTransitLB"
  allocation_method = "Static"
  sku               = "Standard"
  tags              = local.tags
}

resource "azurerm_lb" "transit" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name = "Transit"
  sku  = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.transit_lb.id
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.transit.id
  name            = "BackEndWeb"
}

resource "azurerm_lb_backend_address_pool_address" "web_01" {
  name                    = "Web01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
  virtual_network_id      = module.transit_vnet.vnet_id
  ip_address              = azurerm_network_interface.transit_web_01.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "web_02" {
  name                    = "Web02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
  virtual_network_id      = module.transit_vnet.vnet_id
  ip_address              = azurerm_network_interface.transit_web_02.private_ip_address
}

resource "azurerm_lb_rule" "web" {
  loadbalancer_id                = azurerm_lb.transit.id
  name                           = "WebRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]

  probe_id              = azurerm_lb_probe.web.id
  enable_tcp_reset      = true
  disable_outbound_snat = true
}

resource "azurerm_lb_probe" "web" {
  loadbalancer_id = azurerm_lb.transit.id
  name            = "http-test"
  port            = 80
}
