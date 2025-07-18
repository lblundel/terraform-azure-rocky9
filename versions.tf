terraform {
  required_version = ">= 1.11.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    ansible = {
      source = "ansible/ansible"
      version = "~> 1.3.0"
    }
  }
}
