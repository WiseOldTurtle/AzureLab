variable "resource_group_name" {
  description = "Resource group for security resources"
  type        = string
  default = "rg-nsg-wotlab01"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "UK South"
}

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
