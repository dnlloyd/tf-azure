##### Transit #####
# VMs - public subnet
resource "azurerm_network_interface" "transit_conn_test" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name = "transit-conn-test"
  tags = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.transit_vnet.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.transit_conn_test.id
  }
}

resource "azurerm_public_ip" "transit_conn_test" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name              = "transit-conn-test-pub-ip"
  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1"]
}

resource "azurerm_network_interface_security_group_association" "transit_conn_test" {
  network_interface_id      = azurerm_network_interface.transit_conn_test.id
  network_security_group_id = azurerm_network_security_group.web_vms.id
}

resource "azurerm_linux_virtual_machine" "transit_conn_test" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name           = "transit-conn-test"
  size           = "Standard_F2"
  admin_username = "adminuser"
  tags           = local.tags

  network_interface_ids = [
    azurerm_network_interface.transit_conn_test.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure/adminuser.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# VMs - private subnet
resource "azurerm_network_interface" "transit_web_01" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name = "transit-web-01"
  tags = local.tags

  ip_configuration {
    name                          = "internal"  # TODO: rename to transit-web-01-ip-config
    subnet_id                     = module.transit_vnet.private_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_conn_test_web_01.id  # TODO: remove after testing with and without NAT Gateway
  }
}

resource "azurerm_public_ip" "public_conn_test_web_01" {  # TODO: remove after testing with and without NAT Gateway
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name              = "public-conn-test-web-01"
  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1"]
}

resource "azurerm_linux_virtual_machine" "transit_web_01" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name           = "transit-web-01"
  size           = "Standard_F2"
  admin_username = "adminuser"
  tags           = local.tags

  network_interface_ids = [
    azurerm_network_interface.transit_web_01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure/adminuser.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "transit_web_02" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name = "transit-web-02"
  tags = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.transit_vnet.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "transit_web_02" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name           = "transit-web-02"
  size           = "Standard_F2"
  admin_username = "adminuser"
  tags           = local.tags

  network_interface_ids = [
    azurerm_network_interface.transit_web_02.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure/adminuser.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Security groups
resource "azurerm_network_security_group" "web_vms" {
  location            = azurerm_resource_group.bu_transit_network.location
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name = "WebVMs"
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "web_vms" {
  network_interface_id      = azurerm_network_interface.transit_web_01.id
  network_security_group_id = azurerm_network_security_group.web_vms.id
}

resource "azurerm_network_interface_security_group_association" "web_vms2" {
  network_interface_id      = azurerm_network_interface.transit_web_02.id
  network_security_group_id = azurerm_network_security_group.web_vms.id
}

resource "azurerm_network_security_rule" "web_vms_inbound_allow_http" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_transit_network.name

  name                        = "Inbound_Allow_HTTP"
  network_security_group_name = azurerm_network_security_group.web_vms.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
