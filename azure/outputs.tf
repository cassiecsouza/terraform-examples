output "vm_private_ip" {
  description = "The private IP address of the virtual machine."
  value       = azurerm_network_interface.example.private_ip_address
}
