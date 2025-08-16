terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "mtc-rg"
  location = "westeurope" # Azure expects "westeurope" without space
  tags = {
    environment = "dev"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "mtc_vn" {
  name                = "mtc-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "dev"
  }
}

# Subnet
resource "azurerm_subnet" "etc_subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.mtc_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "mtc_nsg" {
  name                = "mtc-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags = {
    environment = "dev"
  }
}

# NSG Rule
resource "azurerm_network_security_rule" "mtc_dev_rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.mtc_nsg.name
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "mtc_sga" {
  subnet_id                 = azurerm_subnet.etc_subnet.id
  network_security_group_id = azurerm_network_security_group.mtc_nsg.id
}

# Public IP
resource "azurerm_public_ip" "mtc_pip" {
  name                = "mtc-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "dev"
  }
}

# Network Interface
resource "azurerm_network_interface" "mtc_nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.etc_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc_pip.id
  }

  tags = {
    environment = "dev"
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "mtc_vm" {
  name                  = "mtc-vm"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.mtc_nic.id]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/mtcazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address
      user         = "adminuser"
      identityfile = "~/.ssh/mtcazurekey"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "mtc_pip_data" {
  name                = azurerm_public_ip.mtc_pip.name
  resource_group_name = azurerm_resource_group.example.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc_vm.name}: ${data.azurerm_public_ip.mtc_pip_data.ip_address}"
}
