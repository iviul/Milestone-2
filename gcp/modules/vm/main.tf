locals {
  # map “size” strings to real GCP machine types
  size_map = {
    small  = "e2-small"
    medium = "e2-medium"
    large  = "e2-large"
  }

  os_map = {
    ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

resource "google_compute_instance" "vm" {
  for_each     = { for vm in var.vm_instances : vm.name => vm }

  project      = var.project_id
  name         = each.key
  machine_type = lookup(local.size_map, each.value.size, each.value.size)
  zone         = "${var.region}-${each.value.zone}"

  boot_disk {
    initialize_params {
      image = lookup(local.os_map, var.project_os, local.os_map["ubuntu"])
    }
  }

  network_interface {
    subnetwork = lookup(var.subnet_self_links_map, each.value.subnet)
    access_config {}
  }

  tags = each.value.tags

}

output "vm_public_ips" {
  description = "Mapping of VM name → public NAT IP"
  value = {
    for name, inst in google_compute_instance.vm :
    name => inst.network_interface[0].access_config[0].nat_ip
  }
}
