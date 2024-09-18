  provider "azurerm" {
    features {}
  }

resource "azurerm_resource_group" "rg-vnet-wotlab01" {
  name     = "Identity"
  location = "UK South"
}

  resource "azurerm_virtual_network" "frontend" {
    name                = "vn-fe-wotlab01"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name
  }

  resource "azurerm_virtual_network" "backend" {
    name                = "vn-be-wotlab01"
    address_space       = ["10.1.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name
  }

  resource "azurerm_virtual_network" "dev" {
    name                = "vn-dev-wotlab01"
    address_space       = ["10.2.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name
  }

  resource "azurerm_subnet" "frontend_subnet" {
    name                 = "frontend-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.frontend.name
    address_prefixes     = ["10.0.1.0/24"]
  }

  resource "azurerm_subnet" "backend_subnet" {
    name                 = "backend-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.backend.name
    address_prefixes     = ["10.1.1.0/24"]
  }

  resource "azurerm_subnet" "dev_subnet" {
    name                 = "dev-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.dev.name
    address_prefixes     = ["10.2.1.0/24"]
  }
