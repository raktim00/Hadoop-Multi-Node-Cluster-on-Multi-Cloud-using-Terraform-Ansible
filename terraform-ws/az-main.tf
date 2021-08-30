resource "azurerm_resource_group" "az_hadoop_rg" {
  name     = "az-hadoop-rg"
  location = var.az-location
}

resource "azurerm_virtual_network" "az_hadoop_vnet" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg
  ]

  name                = "az-hadoop-network"
  address_space       = [var.az-vpc-cidr-block]
  location            = var.az-location
  resource_group_name = azurerm_resource_group.az_hadoop_rg.name
}

resource "azurerm_subnet" "az_hadoop_subnet" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg,
    azurerm_virtual_network.az_hadoop_vnet
  ]

  name                 = "az-hadoop-subnet"
  resource_group_name  = azurerm_resource_group.az_hadoop_rg.name
  virtual_network_name = azurerm_virtual_network.az_hadoop_vnet.name
  address_prefixes       = [var.az-subnet-cidr-block]
}

resource "azurerm_public_ip" "az_hadoop_publicip" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg
  ]

  for_each = var.az-instance-conf
  name                         = each.value.public-ip
  location                     = var.az-location
  resource_group_name          = azurerm_resource_group.az_hadoop_rg.name
  allocation_method            = "Dynamic"

}

resource "azurerm_network_security_group" "az_hadoop_nsg" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg
  ]

  name                = "az-allowall-nsg"
  location            = var.az-location
  resource_group_name = azurerm_resource_group.az_hadoop_rg.name

  security_rule {
    name                       = "allowall"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "az_hadoop_ni" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg,
    azurerm_subnet.az_hadoop_subnet,
    azurerm_public_ip.az_hadoop_publicip
  ]

  for_each = var.az-instance-conf
  name                        = each.value.network-interface
  location                    = var.az-location
  resource_group_name         = azurerm_resource_group.az_hadoop_rg.name
    
  ip_configuration {
    name                          = "hadoop-Slave-NicConfiguration"
    subnet_id                     = azurerm_subnet.az_hadoop_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_hadoop_publicip[each.value.name].id
  }
}

resource "azurerm_network_interface_security_group_association" "az_hadoop_sg_ni_association" {

  depends_on = [
    azurerm_network_interface.az_hadoop_ni,
    azurerm_network_security_group.az_hadoop_nsg
  ]

  for_each = var.az-instance-conf
  network_interface_id      = azurerm_network_interface.az_hadoop_ni[each.value.name].id
  network_security_group_id = azurerm_network_security_group.az_hadoop_nsg.id
}

resource "azurerm_linux_virtual_machine" "az_hadoop_slave" {

  depends_on = [
    azurerm_resource_group.az_hadoop_rg,
    azurerm_network_interface_security_group_association.az_hadoop_sg_ni_association
  ]

  for_each              = var.az-instance-conf
  name                  = each.value.name
  location              = var.az-location
  resource_group_name   = azurerm_resource_group.az_hadoop_rg.name
  network_interface_ids = [azurerm_network_interface.az_hadoop_ni[each.value.name].id]
  size                  = var.az-instance-type
  
  os_disk {
    name              = each.value.disk-name
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "openlogic"
    offer     = "centos"
    sku       = "8.0"
    version   = "latest"
  }

  computer_name  = each.value.name
  admin_username = "centos"
  
  admin_ssh_key {
    username       = "centos"
    public_key     =  file("../hadoop-multi-cloud-key-public.pub")
  }
}