resource "google_compute_firewall" "rules" {
  for_each = { for n in var.networks_list : n.network_name => n }

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
