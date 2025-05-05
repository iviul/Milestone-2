resource "google_compute_network" "vpc_network" {
  for_each                = { for n in var.networks_list : n.network_name => n }
  name                    = each.value.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = { for n in var.networks_list : n.network_name => n }
  name          = each.value.subnetwork_name
  ip_cidr_range = each.value.subnetwork_cidr
  network       = google_compute_network.vpc_network[each.key].id
  region        = each.value.region
}
