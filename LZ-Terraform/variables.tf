variable "tenant_id" {

}

variable "object_id" {

}

variable "subscription_id" {

}


variable "vm_admin_username" {

}

variable "administrator_login" {

}

variable "ssh-key" {

}

variable "administrator_login_password" {

}

variable "shared_key" {

}

variable "module_instances" {
  type = list(object({
    name        = string
    vnet_name   = string
    subnet_name = string
  }))
}