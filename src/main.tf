provider "azurerm" {
  features {}
  client_id= "a8e8fcb7-ee3a-4260-8942-73671d830a1a"
  client_secret= "nqL8Q~la8_DALpvd1fjTFTefnXHOCDmJNS-gGb3a"
  subscription_id= "fab6bd82-e9fb-4229-91d4-476d41c138fb"
  tenant_id= "dc07ee3a-4d6e-436e-b3f4-29e1cc532ced"
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
}
resource "azurerm_resource_group" "rg12" {
  name     = "terraform-github-cicd"
  location = "East US"
  tags = {
    owner="Ratan"
  }
}

# virtual network information
resource "azurerm_virtual_network" "vnet" {
  name                = "network12"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg12.location
  resource_group_name = azurerm_resource_group.rg12.name
}

# subnet information
resource "azurerm_subnet" "subnet" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.rg12.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# network interface information
resource "azurerm_network_interface" "nic" {
  name                = "ratan-nic"
  location            = azurerm_resource_group.rg12.location
  resource_group_name = azurerm_resource_group.rg12.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# windows virtual machine information
resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "tfa-vm"
  resource_group_name = azurerm_resource_group.rg12.name
  location            = azurerm_resource_group.rg12.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}