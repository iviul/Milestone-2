output "network_self_links" {
  value = { for k, v in google_compute_network.vpc_network : k => v.self_link }
}

output "subnet_self_links" {
  value = { for k, v in google_compute_subnetwork.subnet : k => v.self_link }
}
