provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-nsg-wotlab01" {
  name     = "Identity"
  location = "UK South"
}

resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Deny all inbound traffic except VNET internal traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow VNET-to-VNET communication
  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}
