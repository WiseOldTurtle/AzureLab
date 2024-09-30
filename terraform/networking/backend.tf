terraform {
  backend "azurerm" {
    # Use environment variables for backend configuration
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = var.state_file
    resource_group_name  = var.resource_group_name
  }
}