provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "example" {
  name         = "wfdemo-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Leave empty for ephemeral IP or specify a static IP
    }
  }

  tags = ["wfdemo"]
}