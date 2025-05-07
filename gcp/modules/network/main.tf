locals {
  # map ACL name → cidr
  acls_map = { for a in var.acls : a.name => a.cidr }
}

# 1) The single VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

# 2) Regional subnets
resource "google_compute_subnetwork" "subnet" {
  for_each      = { for s in var.subnets : s.name => s }
  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# 3) Ingress firewalls
resource "google_compute_firewall" "ingress" {
  for_each    = {
    for sg in var.security_groups : sg.name => sg
    if length(sg.ingress) > 0
  }

  name        = each.value.name
  network     = google_compute_network.vpc.self_link
  target_tags = each.value.attach_to

  dynamic "allow" {
    for_each = each.value.ingress
    content {
      protocol = allow.value.protocol
      ports    = [tostring(allow.value.port)]
    }
  }

  source_ranges = [
    for rule in each.value.ingress :
    lookup(local.acls_map, rule.source, rule.source)
          if contains(keys(local.acls_map), rule.source)
  ]
}

# 4) Egress firewalls
resource "google_compute_firewall" "egress" {
  for_each    = {
    for sg in var.security_groups : sg.name => sg
    if length(sg.egress) > 0
  }

  name        = "${each.key}-egress"
  network     = google_compute_network.vpc.self_link
  target_tags = each.value.attach_to
  direction   = "EGRESS"

  dynamic "allow" {
    for_each = each.value.egress
    content {
      protocol = allow.value.protocol
      ports    = [tostring(allow.value.port)]
    }
  }

 destination_ranges = [
    for rule in each.value.egress :
      lookup(local.acls_map, rule.destination, null)
    if contains(keys(local.acls_map), rule.destination)
  ]
}
