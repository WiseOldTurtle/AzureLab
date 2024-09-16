provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "frontend" {
  name                = "vn-fe-wotlab01"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet {
    name             = "frontend-subnet"
    address_prefixes = "10.0.1.0/24"
  }
}

resource "azurerm_virtual_network" "backend" {
  name                = "vn-be-wotlab01"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet {
    name             = "backend-subnet"
    address_prefixes = "10.1.1.0/24"
  }
}

resource "azurerm_virtual_network" "dev" {
  name                = "vn-dev-wotlab01"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet {
    name             = "dev-subnet"
    address_prefixes = "10.2.1.0/24"
  }
}
