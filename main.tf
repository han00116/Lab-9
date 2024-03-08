provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "han_rg" {
  name     = "terraform-thing"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "han_vnet" {
  name                = "han-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.han_rg.location
  resource_group_name = azurerm_resource_group.han_rg.name
}

# Subnet
resource "azurerm_subnet" "han_subnet" {
  name                 = "han-subnet"
  resource_group_name  = azurerm_resource_group.han_rg.name
  virtual_network_name = azurerm_virtual_network.han_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "han_public_ip" {
  name                = "han-public-ip"
  location            = azurerm_resource_group.han_rg.location
  resource_group_name = azurerm_resource_group.han_rg.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "han_nic" {
  name                = "han-nic"
  location            = azurerm_resource_group.han_rg.location
  resource_group_name = azurerm_resource_group.han_rg.name

  ip_configuration {
    name                          = "han-nic-configuration"
    subnet_id                     = azurerm_subnet.han_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.han_public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "han_vm" {
  name                = "han-vm"
  location            = azurerm_resource_group.han_rg.location
  resource_group_name = azurerm_resource_group.han_rg.name
  size                = "Standard_DS1_v2"
  admin_username      = "han00116"
  network_interface_ids = [
    azurerm_network_interface.han_nic.id
  ]

  admin_ssh_key {
    username   = "han00116"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}