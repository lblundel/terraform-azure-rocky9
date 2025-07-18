variable "admin_password" {
  description = "The admin password for the Linux VM"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "The admin username for the Linux VM"
  type        = string
  default     = "adminuser"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "shutdown_notification_email" {
  description = "The email address to send shutdown notifications to"
  type        = string
}

variable "vm_size" {
  description = "The size of the rockylinux9 Linux VM"
  type        = string
  default     = "Standard_B1ms"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default = {}
}

// add a variable vnet_subnet_id
variable "vnet_subnet_id" {
  description = "The ID of the subnet to deploy the VM into"
  type        = string
}
