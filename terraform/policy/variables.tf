# variable "subscription_id" {
#   description = "The Azure Subscription ID."
#   type        = string
# }

variable "storage_account_name" {
  description = "The name of the storage account for the backend."
  type        = string
}

variable "container_name" {
  description = "The name of the container in Azure Storage."
  type        = string
}

variable "state_file" {
  description = "The name of the state file."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}