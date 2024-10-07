terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "terraformstateprojwot1"
      container_name       = "tfstate"
      key                  = "networking.tfstate"
  }
}

provider "azurerm" {
  features {}
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
      address_prefix    = subnet.value.address
    }
  }
}

# VNet Peering Logic
# Count -1 ensures that the count, counts the correct number of VNETs
resource "azurerm_virtual_network_peering" "vnet_peering" {
  count = length(var.vnetloop) * (length(var.vnetloop) - 1)

  # Local VNet (peering from) floor command makes sure that each VNet peers with all others apart from itself. 
  name                = "peering-${azurerm_virtual_network.corenetworks[floor(count.index / (length(var.vnetloop) - 1))].name}-to-${azurerm_virtual_network.corenetworks[count.index % (length(var.vnetloop) - 1)].name}"
  resource_group_name = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.corenetworks[floor(count.index / (length(var.vnetloop) - 1))].name

  # Remote VNet (peering to)
  remote_virtual_network_id = azurerm_virtual_network.corenetworks[count.index % (length(var.vnetloop) - 1)].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}