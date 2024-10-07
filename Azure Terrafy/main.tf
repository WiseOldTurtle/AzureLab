resource "azurerm_resource_group" "res-0" {
  location = "uksouth"
  name     = "rg-vnet-wotlab01"
}
resource "azurerm_network_security_group" "res-1" {
  location            = "uksouth"
  name                = "nsg-wot-uks-application01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_group" "res-2" {
  location            = "uksouth"
  name                = "nsg-wot-uks-cgm01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_group" "res-3" {
  location            = "uksouth"
  name                = "nsg-wot-uks-database01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_group" "res-4" {
  location            = "uksouth"
  name                = "nsg-wot-uks-jumphosts01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_group" "res-5" {
  location            = "uksouth"
  name                = "nsg-wot-uks-trusted01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_group" "res-6" {
  location            = "uksouth"
  name                = "nsg-wot-uks-webserver01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_route_table" "res-7" {
  location            = "uksouth"
  name                = "UDRName"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_route" "res-8" {
  address_prefix         = "2.2.2.0/24"
  name                   = "udr-wot--uksbackend"
  next_hop_in_ip_address = "2.2.2.10"
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = "rg-vnet-wotlab01"
  route_table_name       = "UDRName"
  depends_on = [
    azurerm_route_table.res-7,
  ]
}
resource "azurerm_route" "res-9" {
  address_prefix         = "1.1.1.0/24"
  name                   = "udr-wot--uksfrontend"
  next_hop_in_ip_address = "1.1.1.10"
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = "rg-vnet-wotlab01"
  route_table_name       = "UDRName"
  depends_on = [
    azurerm_route_table.res-7,
  ]
}
resource "azurerm_virtual_network" "res-10" {
  address_space       = ["10.60.16.0/24"]
  location            = "uksouth"
  name                = "vn-wot-uks-core01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-11" {
  address_prefixes     = ["10.60.16.128/26"]
  name                 = "sn-wot-uks-activedirectory"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-core01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_subnet" "res-12" {
  address_prefixes     = ["10.60.16.0/26"]
  name                 = "sn-wot-uks-application01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-core01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_subnet" "res-13" {
  address_prefixes     = ["10.60.16.64/26"]
  name                 = "sn-wot-uks-database01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-core01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_subnet" "res-14" {
  address_prefixes     = ["10.60.16.192/28"]
  name                 = "sn-wot-uks-webserver01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-core01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_virtual_network_peering" "res-15" {
  name                      = "peering-to-remote-vnet"
  remote_virtual_network_id = "/subscriptions/d9d2ecd3-56a0-4f15-bae9-04b37c0d4335/resourceGroups/rg-vnet-wotlab01/providers/Microsoft.Network/virtualNetworks/vn-wot-uks-hub01"
  resource_group_name       = "rg-vnet-wotlab01"
  virtual_network_name      = "vn-wot-uks-core01"
  depends_on = [
    azurerm_virtual_network.res-10,
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_virtual_network" "res-16" {
  address_space       = ["10.60.0.0/23"]
  location            = "uksouth"
  name                = "vn-wot-uks-hub01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-17" {
  address_prefixes     = ["10.60.0.0/27"]
  name                 = "AzureBastionSubnet"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-hub01"
  depends_on = [
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_subnet" "res-18" {
  address_prefixes     = ["10.60.0.128/27"]
  name                 = "sn-wot-uks-cloudguardmgmt"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-hub01"
  depends_on = [
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_subnet" "res-19" {
  address_prefixes     = ["10.60.0.32/28"]
  name                 = "sn-wot-uks-firewall01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-hub01"
  depends_on = [
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_subnet" "res-20" {
  address_prefixes     = ["10.60.0.48/28"]
  name                 = "sn-wot-uks-firewall02"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-hub01"
  depends_on = [
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_subnet" "res-21" {
  address_prefixes     = ["10.60.0.64/26"]
  name                 = "sn-wot-uks-management01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-hub01"
  depends_on = [
    azurerm_virtual_network.res-16,
  ]
}
resource "azurerm_virtual_network" "res-22" {
  address_space       = ["10.60.112.0/25"]
  location            = "uksouth"
  name                = "vn-wot-uks-preprod01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-23" {
  address_prefixes     = ["10.60.112.0/27"]
  name                 = "sn-wot-uks-application01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-preprod01"
  depends_on = [
    azurerm_virtual_network.res-22,
  ]
}
resource "azurerm_subnet" "res-24" {
  address_prefixes     = ["10.60.112.32/27"]
  name                 = "sn-wot-uks-database01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-preprod01"
  depends_on = [
    azurerm_virtual_network.res-22,
  ]
}
resource "azurerm_subnet" "res-25" {
  address_prefixes     = ["10.60.112.64/27"]
  name                 = "sn-wot-uks-webserver01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-preprod01"
  depends_on = [
    azurerm_virtual_network.res-22,
  ]
}
resource "azurerm_virtual_network" "res-26" {
  address_space       = ["10.60.32.0/24"]
  location            = "uksouth"
  name                = "vn-wot-uks-prod01"
  resource_group_name = "rg-vnet-wotlab01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-27" {
  address_prefixes     = ["10.60.32.0/26"]
  name                 = "sn-wot-uks-application01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-prod01"
  depends_on = [
    azurerm_virtual_network.res-26,
  ]
}
resource "azurerm_subnet" "res-28" {
  address_prefixes     = ["10.60.32.64/26"]
  name                 = "sn-wot-uks-database01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-prod01"
  depends_on = [
    azurerm_virtual_network.res-26,
  ]
}
resource "azurerm_subnet" "res-29" {
  address_prefixes     = ["10.60.32.128/26"]
  name                 = "sn-wot-uks-webserver01"
  resource_group_name  = "rg-vnet-wotlab01"
  virtual_network_name = "vn-wot-uks-prod01"
  depends_on = [
    azurerm_virtual_network.res-26,
  ]
}
