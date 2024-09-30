terraform {
  backend "azurerm" {
    storage_account_name = getenv("TF_VAR_STORAGE_ACCOUNT_NAME")
    container_name       = getenv("TF_VAR_CONTAINER_NAME")
    key                  = getenv("TF_VAR_STATE_FILE")
    resource_group_name  = getenv("TF_VAR_RESOURCE_GROUP_NAME")
  }
}