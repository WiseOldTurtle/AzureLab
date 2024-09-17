output "frontend_nsg_id" {
  description = "ID of the frontend NSG"
  value       = azurerm_network_security_group.frontend_nsg.id
}
