resource "google_compute_network" "vpc_network" {
  name                    = "class-schedule-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "class-schedule-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
}


resource "google_compute_firewall" "rules" {
    name    = "fw-rules"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports    = ["80", "443", "22", "8080"]
    }

    source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_instance" "vm_instance" {
  name         = "class-schedule-vm-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
       image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
  subnetwork = google_compute_subnetwork.subnet.self_link
  access_config {
    // Ephemeral IP
  }
}
}
