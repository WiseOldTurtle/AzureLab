terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-rg"
    storage_account_name  = "terraformstateprojwot1"
    container_name        = "tfstate"
    key                   = "networking/terraform.tfstate"
  }
}
