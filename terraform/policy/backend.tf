terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-rg"
    storage_account_name  = "terraformstate01"
    container_name        = "tfstate"
    key                   = "policy/terraform.tfstate"
  }
}
