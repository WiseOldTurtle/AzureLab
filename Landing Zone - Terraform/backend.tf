terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-01"
    storage_account_name = "tfbackendstore"
    container_name       = "tfbackend"
    key                  = "prod.terraform.tfstate"
  }
}