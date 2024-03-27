variable "project_id" {
  description = "The ID of the Google Cloud Platform project."
}

variable "region" {
  description = "The region where the VM will be created."
}

variable "zone" {
  description = "The zone where the VM will be created."
}

variable "machine_type" {
  description = "The machine type for the VM."
}

variable "image" {
  description = "The image to use for the VM's boot disk."
}