output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "firewall_rule_name" {
  description = "The name of the firewall rule"
  value       = google_compute_firewall.allow_postgres.name
}

# output "ssh_firewall_rule_name" {
#   description = "The name of the SSH firewall rule"
#   value       = google_compute_firewall.allow_ssh.name
# }

output "vpc_network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}
