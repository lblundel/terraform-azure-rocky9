resource "azurerm_network_interface" "nic_rockylinux9" {
  location            = var.location
  name                = "nic-rockylinux9"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vnet_subnet_id
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags = var.tags
}

resource "azurerm_public_ip" "public_ip" {
  allocation_method   = "Static"
  domain_name_label   = "rockylinux9vm"
  location            = var.location
  name                = "rockylinux9-public-ip"
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  idle_timeout_in_minutes = 30
  tags                = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association_rockylinux9" {
  network_interface_id      = azurerm_network_interface.nic_rockylinux9.id
  network_security_group_id = azurerm_network_security_group.nsg_rockylinux9.id
  depends_on = [
    azurerm_network_interface.nic_rockylinux9,
    azurerm_network_security_group.nsg_rockylinux9,
  ]
}

resource "azurerm_network_security_group" "nsg_rockylinux9" {
  location            = var.location
  name                = "rockylinux9-vm-securityGroup"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "ssh_rule_rockylinux9" {
  access                      = "Allow"
  description                 = "Allow SSH"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.nsg_rockylinux9.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg_rockylinux9,
  ]
}

resource "azurerm_network_security_rule" "dns_tcp_rule_rockylinux9" {
  access                      = "Allow"
  description                 = "Allow DNS TCP"
  destination_address_prefix  = "*"
  destination_port_range      = "53"
  direction                   = "Inbound"
  name                        = "DNS-TCP"
  network_security_group_name = azurerm_network_security_group.nsg_rockylinux9.name
  priority                    = 101
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg_rockylinux9,
  ]
}

resource "azurerm_network_security_rule" "dns_udp_rule_rockylinux9" {
  access                      = "Allow"
  description                 = "Allow DNS UDP"
  destination_address_prefix  = "*"
  destination_port_range      = "53"
  direction                   = "Inbound"
  name                        = "DNS-UDP"
  network_security_group_name = azurerm_network_security_group.nsg_rockylinux9.name
  priority                    = 102
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg_rockylinux9,
  ]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content              = tls_private_key.ssh_key.private_key_pem
  filename             = "${path.cwd}/.ssh/id_rsa"
  directory_permission = "0700"
  file_permission      = "0600"
}

resource "local_file" "public_key" {
  content              = tls_private_key.ssh_key.public_key_openssh
  filename             = "${path.cwd}/.ssh/id_rsa.pub"
  directory_permission = "0700"
  file_permission      = "0644"
}

resource "azurerm_linux_virtual_machine" "rockylinux9_vm" {
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  location                        = var.location
  name                            = "rockylinux9-vm"
  network_interface_ids           = [azurerm_network_interface.nic_rockylinux9.id]
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  boot_diagnostics {
    storage_account_uri = "https://${var.storage_account_name}.blob.core.windows.net/"
  }
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
  }
  plan {
    name      = "9-base"
    product   = "rockylinux-x86_64"
    publisher = "resf"
  }
  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
  tags = var.tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown_schedule" {
  daily_recurrence_time = "2100"
  location              = var.location
  timezone              = "W. Europe Standard Time"
  virtual_machine_id    = azurerm_linux_virtual_machine.rockylinux9_vm.id
  notification_settings {
    enabled         = true
    time_in_minutes = 30
    email           = var.shutdown_notification_email
  }
  depends_on = [
    azurerm_linux_virtual_machine.rockylinux9_vm
  ]
  tags = var.tags
}