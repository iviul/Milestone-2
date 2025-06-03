output "forwarding_rule_ip" {
  description = "The IP address of the regional TCP load balancer"
  value       = google_compute_forwarding_rule.k3s_forwarding_rule.ip_address
}

# output "ip_address" {
#   value = google_compute_global_address.lb_address.address  // adjust this reference based on your resource
# }
