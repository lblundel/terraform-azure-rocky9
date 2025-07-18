# terraform-azure-rocky9

This Terraform module deploys a Rocky Linux 9 virtual machine (VM) on Microsoft Azure. It automates the creation of all required Azure resources, including network interfaces, public IP, network security group, and VM shutdown schedule, to provide a ready-to-use Rocky Linux 9 environment.

## Features

- Deploys a Rocky Linux 9 VM with customizable size and admin credentials.
- Creates and attaches a network interface and static public IP.
- Configures a Network Security Group with rules for SSH and DNS (TCP/UDP).
- Generates and stores SSH keys locally.
- Enables Azure DevTest Lab VM shutdown schedule with email notifications.
- Supports custom tags for all resources.
- Integrates with Ansible for post-provisioning automation (optional).

## Usage

```hcl
module "rocky9" {
  source = "github.com/lblundel/terraform-azure-rocky9"

  admin_username              = var.admin_username
  admin_password              = var.admin_password
  location                    = var.location
  resource_group_name         = azurerm_resource_group.this.name
  vm_size                     = "Standard_D2s_v3"
  storage_account_name        = azurerm_storage_account.storage_account.name
  vnet_subnet_id              = module.vnet.subnets["lan1"].resource_id
  shutdown_notification_email = var.shutdown_notification_email
  tags                        = var.tags
}
```

## Inputs

| Name                        | Description                                      | Type   | Default | Required |
|-----------------------------|--------------------------------------------------|--------|---------|----------|
| `admin_username`            | Admin username for the VM                        | string | n/a     | yes      |
| `admin_password`            | Admin password for the VM                        | string | n/a     | yes      |
| `location`                  | Azure region                                     | string | n/a     | yes      |
| `resource_group_name`       | Name of the resource group                       | string | n/a     | yes      |
| `vm_size`                   | Azure VM size                                    | string | n/a     | yes      |
| `storage_account_name`      | Storage account name for boot diagnostics        | string | n/a     | yes      |
| `vnet_subnet_id`            | Subnet ID for the VM NIC                         | string | n/a     | yes      |
| `shutdown_notification_email` | Email for VM shutdown notifications            | string | n/a     | yes      |
| `tags`                      | Tags to apply to resources                       | map    | `{}`    | no       |

## Outputs

- `rockylinux9_vm_id` – The ID of the deployed Rocky Linux 9 VM.
- `rockylinux9_public_ip` – The public IP address of the VM.
- `rockylinux9_private_ip` – The private IP address of the VM.

## Requirements

- Terraform >= 1.9
- AzureRM provider >= 3.74
- Ansible provider (optional, for automation)

## License

MIT