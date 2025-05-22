output "vpc_self_links" {
  description = "Map of network name to VPC self_link"
  value = {
    for name, vpc in google_compute_network.vpc :
    name => vpc.self_link
  }
}

output "subnet_self_links" {
  description = "Map from network-subnet key to self_link"
  value = {
    for key, subnet in google_compute_subnetwork.subnet :
    key => subnet.self_link
  }
}

output "subnet_self_links_by_name" {
  description = "Map from subnet name to self_link (for backward compatibility)"
  value = {
    for key, subnet in google_compute_subnetwork.subnet :
    subnet.name => subnet.self_link
  }
}