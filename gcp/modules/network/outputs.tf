output "vpc_self_link" {
  description = "Self-link of the single VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_self_links" {
  description = "Map from subnet name → self_link"
  value = {
    for name, subnet in google_compute_subnetwork.subnet :
    name => subnet.self_link
  }
}