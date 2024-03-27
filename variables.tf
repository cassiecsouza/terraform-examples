variable "resource_group_name" {
  description = "The name of the resource group."
}

variable "location" {
  description = "The Azure region where resources will be created."
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
}

variable "address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the subnet."
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet."
  type        = list(string)
}

variable "network_interface_name" {
  description = "The name of the network interface."
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration."
}

variable "private_ip_allocation" {
  description = "The method used to allocate the private IP address."
}

variable "virtual_machine_name" {
  description = "The name of the virtual machine."
}

variable "vm_size" {
  description = "The size of the virtual machine."
}

variable "publisher" {
  description = "The publisher of the VM image."
}

variable "offer" {
  description = "The offer of the VM image."
}

variable "sku" {
  description = "The SKU of the VM image."
}

variable "version" {
  description = "The version of the VM image."
}

variable "admin_username" {
  description = "The admin username for the virtual machine."
}

variable "admin_password" {
  description = "The admin password for the virtual machine."
}

variable "tags" {
  description = "A map of tags for the resources."
  type        = map(string)
}

