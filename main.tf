# Create a resource group
resource "azurerm_resource_group" "demo-RG" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo-RG.location
  resource_group_name = azurerm_resource_group.demo-RG.name
}

# Create a subnet
resource "azurerm_subnet" "demo-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.demo-RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "example" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.demo-RG.location
  resource_group_name = azurerm_resource_group.demo-RG.name
  allocation_method   = "Static"
}

# Create a network security group
resource "azurerm_network_security_group" "example" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.demo-RG.location
  resource_group_name = azurerm_resource_group.demo-RG.name
}

# Create a network interface
resource "azurerm_network_interface" "example" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.demo-RG.location
  resource_group_name = azurerm_resource_group.demo-RG.name

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = azurerm_subnet.demo-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Create a virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = var.vm_name
  location              = azurerm_resource_group.demo-RG.location
  resource_group_name   = azurerm_resource_group.demo-RG.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.vm_size # Change this to your desired VM size

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name              = var.os_disk_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.os_disk_type
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password # Change this to your desired password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
