  provider "azurerm" {
    features {}
  }

# input variable mapping the function from Tfvars
variable "vnetloop" {
  type = list(object({
    vnet_name     = string
    address_space = list(string)
    subnets = list(object({
      name    = string
      address = string
    }))
  }))
}

resource "azurerm_resource_group" "networking" {
  name     = var.resource_group_name
  location = var.location
}

# Create VNET using the variable mapping created above to iterate (note to self: "same as a foreach loop in arm")
resource "azurerm_virtual_network" "corenetworks" {
  count = length(var.vnetloop)

  name                = var.vnetloop[count.index].vnet_name
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = var.vnetloop[count.index].address_space

  dynamic "subnet" {
    for_each = var.vnetloop[count.index].subnets

    content {
      name              = subnet.value.name
      address_prefixes  = subnet.value.address
    }
  }
}

  # resource "azurerm_virtual_network" "frontend" {
  #   name                = "vn-fe-wotlab01"
  #   address_space       = ["10.0.0.0/16"]
  #   location            = var.location
  #   resource_group_name = var.resource_group_name
  # }

  # resource "azurerm_virtual_network" "backend" {
  #   name                = "vn-be-wotlab01"
  #   address_space       = ["10.1.0.0/16"]
  #   location            = var.location
  #   resource_group_name = var.resource_group_name
  # }

  # resource "azurerm_virtual_network" "dev" {
  #   name                = "vn-dev-wotlab01"
  #   address_space       = ["10.2.0.0/16"]
  #   location            = var.location
  #   resource_group_name = var.resource_group_name
  # }

  # resource "azurerm_subnet" "frontend_subnet" {
  #   name                 = "frontend-subnet"
  #   resource_group_name  = var.resource_group_name
  #   virtual_network_name = azurerm_virtual_network.frontend.name
  #   address_prefixes     = ["10.0.1.0/24"]
  # }

  # resource "azurerm_subnet" "backend_subnet" {
  #   name                 = "backend-subnet"
  #   resource_group_name  = var.resource_group_name
  #   virtual_network_name = azurerm_virtual_network.backend.name
  #   address_prefixes     = ["10.1.1.0/24"]
  # }

  # resource "azurerm_subnet" "dev_subnet" {
  #   name                 = "dev-subnet"
  #   resource_group_name  = var.resource_group_name
  #   virtual_network_name = azurerm_virtual_network.dev.name
  #   address_prefixes     = ["10.2.1.0/24"]
  # }
