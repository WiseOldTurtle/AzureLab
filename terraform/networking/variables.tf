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

# input variable mapping the function from Tfvars
variable "vnetloop" {
  type = list(object({
    vnet_name     = string
    address_space = list(string)
    subnets = list(object({
      name    = string
      address = string
    }))
  }))
}