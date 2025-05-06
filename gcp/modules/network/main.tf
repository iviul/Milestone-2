resource "google_compute_network" "vpc_network" {
  for_each = { for net in var.networks : net.network_name => net }

  name                    = each.value.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  for_each = { for net in var.networks : net.network_name => net }

  name          = each.value.subnetwork_name
  ip_cidr_range = each.value.subnetwork_cidr
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.key].id
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "mesh2-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network["mesh2"].self_link
}

resource "google_service_networking_connection" "private_connection" {
  provider = google
  network  = google_compute_network.vpc_network["mesh2"].self_link
  service  = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}


resource "google_compute_firewall" "rules" {
  for_each = { for n in var.networks : n.network_name => n }

  name    = "${each.value.network_name}-fw"
  network =  var.network_self_links[each.value.network_name]

  dynamic "allow" {
    for_each = each.value.ports
    content {
      protocol = "tcp"
      ports    = [allow.value]
    }
  }
  source_ranges = ["0.0.0.0/0"]
}

