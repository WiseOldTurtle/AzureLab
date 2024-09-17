variable "resource_group_name" {
  description = "Resource group for the networking infrastructure"
  type        = string
  default     ="rg-vnet-wotlab01"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "UK South"
}

variable "TENANT_ID" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "CLIENT_ID" {
  description = "The Azure Client ID."
  type        = string
}

variable "SECRET" {
  description = "The Azure Client Secret."
  type        = string
}

variable "SUBSCRIPTION_ID" {
  description = "The Azure Subscription ID."
  type        = string
}
