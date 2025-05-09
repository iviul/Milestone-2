locals {
  # map ACL name → cidr
  acls_map = { for a in var.acls : a.name => a.cidr }
  
  # Create a map of VPC name to VPC for easier lookup
  vpcs_map = { for vpc in var.networks : vpc.name => vpc }
  
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
  for_each      = {
    for subnet in flatten([
      for network in var.networks : [
        for subnet in network.subnets : {
          key = "${network.name}-${subnet.name}"
          network_name = network.name
          subnet_data = subnet
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
  for_each    = {
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
resource "google_compute_firewall" "egress" {
  for_each    = {
    for sg in var.security_groups : sg.name => sg
    if length(sg.egress) > 0
  }

  name        = "${each.key}-egress"
  network     = google_compute_network.vpc[each.value.vpc].self_link
  target_tags = each.value.attach_to
  direction   = "EGRESS"

  dynamic "allow" {
    for_each = each.value.egress
    content {
      protocol = allow.value.protocol
      ports    = [tostring(allow.value.port)]
    }
  }

  # Handle destination ranges properly - either use CIDR from ACLs or leave empty for all destinations
  destination_ranges = distinct(flatten([
    for rule in each.value.egress : 
      contains(keys(local.acls_map), rule.destination) ? [local.acls_map[rule.destination]] : ["0.0.0.0/0"]
    if !contains(keys(local.sg_to_instances_map), rule.destination)
  ]))
  
  # For destinations that are security groups, we can't directly set target tags for egress
  # This is a limitation of GCP. In a real implementation, you'd need to use network tags or
  # service accounts to identify targets accurately
}
