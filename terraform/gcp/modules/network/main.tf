locals {
  acls_map = { for a in var.acls : a.name => a.cidr }

  vpcs_map = { for vpc in var.networks : vpc.name => vpc }
  psa_ranges_map = {
    for net in var.networks :
    net.name => {
      name  = "psa-range-${net.name}"
      cidr  = "${net.psa_range}"
    }
  }

  # Create a map of security group name to the instances it's attached to
  sg_to_instances_map = { for sg in var.security_groups : sg.name => sg.attach_to }
}

# 1) Create VPCs for each network
resource "google_compute_network" "vpc" {
  for_each                = local.vpcs_map
  name                    = "${var.project_id}-${each.key}-vpc"
  auto_create_subnetworks = false
}

# 2) Regional subnets for each network
resource "google_compute_subnetwork" "subnet" {
  for_each = {
    for subnet in flatten([
      for network in var.networks : [
        for subnet in network.subnets : {
          key          = "${network.name}-${subnet.name}"
          network_name = network.name
          subnet_data  = subnet
        }
      ]
    ]) : subnet.key => subnet
  }

  name          = each.value.subnet_data.name
  ip_cidr_range = each.value.subnet_data.cidr
  region        = var.region
  network       = google_compute_network.vpc[each.value.network_name].id
}

resource "google_compute_firewall" "ingress" {
  for_each = {
    for sg in var.security_groups : sg.name => sg
    if length(sg.ingress) > 0
  }

  name        = each.value.name
  network     = google_compute_network.vpc[each.value.vpc].self_link
  target_tags = each.value.attach_to

 dynamic "allow" {
    for_each = each.value.ingress
    content {
      protocol = allow.value.protocol
      ports    = [tostring(allow.value.port)]
    }
  }

  # Handle source ranges properly - either use CIDR from ACLs or default to 0.0.0.0/0
  source_ranges = distinct(flatten([
    for rule in each.value.ingress :
    contains(keys(local.acls_map), rule.source) ? [local.acls_map[rule.source]] : ["0.0.0.0/0"]
    if !contains(keys(local.sg_to_instances_map), rule.source)
  ]))

  # Handle source tags when source is another security group
  source_tags = distinct(flatten([
    for rule in each.value.ingress :
    contains(keys(local.sg_to_instances_map), rule.source) ? local.sg_to_instances_map[rule.source] : []
  ]))
}

# 4) Egress firewalls
# resource "google_compute_firewall" "egress" {
#   for_each = {
#     for sg in var.security_groups : sg.name => sg
#     if length(sg.egress) > 0
#   }

#   name        = "${each.key}-egress"
#   network     = google_compute_network.vpc[each.value.vpc].self_link
#   target_tags = each.value.attach_to
#   direction   = "EGRESS"

#   dynamic "allow" {
#     for_each = each.value.egress
#     content {
#       protocol = allow.value.protocol
#       ports    = [tostring(allow.value.port)]
#     }
#   }

#   # Handle destination ranges properly - either use CIDR from ACLs or leave empty for all destinations
#   destination_ranges = distinct(flatten([
#     for rule in each.value.egress :
#     contains(keys(local.acls_map), rule.destination) ? [local.acls_map[rule.destination]] : ["0.0.0.0/0"]
#     if !contains(keys(local.sg_to_instances_map), rule.destination)
#   ]))

# }

resource "google_compute_router" "nat_router" {
  for_each = google_compute_network.vpc

  name    = "${each.key}-nat-router"
  network = each.value.self_link
  region  = var.region
}

resource "google_compute_router_nat" "cloud_nat" {
  for_each = local.vpcs_map

  name   = "${each.key}-nat"
  router = google_compute_router.nat_router[each.key].name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
resource "google_compute_firewall" "lb_health_check" {
  name      = "${var.project_id}-k3s-vpc-lb-health-check"
  network   = google_compute_network.vpc["k3s-vpc"].self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.health_check_port)]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["k3s-worker", "k3s-master"] 
}

resource "google_compute_global_address" "default" {
  for_each = local.psa_ranges_map

  name          = each.value.name
  project       = var.project_id
  provider      = google-beta
  ip_version    = "IPV4"
  prefix_length = 16
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc[each.key].self_link
  # address       = each.value.cidr
}

resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = local.psa_ranges_map

  provider                = google-beta
  network                 = google_compute_network.vpc[each.key].self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default[each.key].name]
  update_on_creation_fail = true
  
  deletion_policy = "ABANDON"
}
