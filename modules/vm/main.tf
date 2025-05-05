resource "google_compute_instance" "vm_instance" {
  for_each     = { for v in var.vms_list : v.vm_name => v }
  name         = each.value.vm_name
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = each.value.image
    }
  }

  network_interface {
    subnetwork    = var.subnet_self_links_map[each.value.network]
    access_config {}
  }

  metadata = each.value.metadata
  tags     = each.value.tags
}
