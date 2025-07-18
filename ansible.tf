resource "ansible_group" "dns_servers" {
  name = "dns_servers"
  children = [ 
    ansible_group.external_dns.name, 
    ansible_group.internal_dns.name 
  ]
}

resource "ansible_group" "external_dns" {
  name = "external_dns"
}

resource "ansible_group" "internal_dns" {
  name = "internal_dns"
}

resource "ansible_host" "rockylinux9_vm" {
  name = azurerm_linux_virtual_machine.rockylinux9_vm.name
  groups             = [ansible_group.internal_dns.name]
  variables = {
    public_ip_fqdn     = join(".", [azurerm_public_ip.public_ip.domain_name_label, var.location, "cloudapp.azure.com"])
    ansible_user       = var.admin_username
    ansible_host       = azurerm_public_ip.public_ip.ip_address
    ansible_ssh_private_key_file        = "${path.cwd}/.ssh/id_rsa"
  }
}

/*
resource "ansible_playbook" "dns_playbook" {
  playbook = pathexpand("~/scm/ansible/site.yml")
  name = ansible_host.rockylinux9_vm.name
  check_mode = true
  diff_mode = true
  verbosity = 1
  replayable              = true
  ansible_playbook_binary = "/path/to/binary/.local/bin/ansible-playbook"
  vault_password_file     = "/path/to/vault"
  tags =["bind"]
}
*/

