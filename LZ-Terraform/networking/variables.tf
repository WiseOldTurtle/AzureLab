variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "subscription_id" {
  type = string
}


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
