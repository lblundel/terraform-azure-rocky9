output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "public_ip_domain_name_label" {
  value = azurerm_public_ip.public_ip.domain_name_label
}

output "public_ip_fqdn" {
  value = join(".", [azurerm_public_ip.public_ip.domain_name_label, var.location, "cloudapp.azure.com"])
}

