##### Transit #####
# VMs
resource "azurerm_network_interface" "transit_web_01" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name = "transit-web-01"
  tags = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.transit_vnet.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "transit_web_01" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

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
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  name = "transit-web-02"
  tags = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.transit_vnet.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "transit_web_02" {
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

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
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

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
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

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

##### Spoke01 ########
# VMs
resource "azurerm_network_interface" "spoke01_web_01" {
  location            = azurerm_resource_group.bu_tf_testing_spoke_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name = "spoke01-web-01"
  tags = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.spoke01_vnet.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke01_web_01" {
  location            = azurerm_resource_group.bu_tf_testing_spoke_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name           = "spoke01-web-01"
  size           = "Standard_F2"
  admin_username = "adminuser"
  tags           = local.tags

  network_interface_ids = [
    azurerm_network_interface.spoke01_web_01.id,
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
resource "azurerm_network_security_group" "spoke01_web_vms" {
  location            = azurerm_resource_group.bu_tf_testing_spoke_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name = "Spoke01WebVMs"
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "spoke01_web_vms" {
  network_interface_id      = azurerm_network_interface.spoke01_web_01.id
  network_security_group_id = azurerm_network_security_group.spoke01_web_vms.id
}

resource "azurerm_network_security_rule" "spoke01_web_vms_inbound_allow_all" { # TODO: Refine
  resource_group_name = azurerm_resource_group.bu_tf_testing_spoke_vnet.name

  name                        = "Inbound_Allow_All"
  network_security_group_name = azurerm_network_security_group.spoke01_web_vms.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
