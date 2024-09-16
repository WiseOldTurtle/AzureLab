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

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "client_id" {
  description = "The Azure Client ID."
  type        = string
}

variable "client_secret" {
  description = "The Azure Client Secret."
  type        = string
}

variable "subscription_id" {
  description = "The Azure Subscription ID."
  type        = string
}
