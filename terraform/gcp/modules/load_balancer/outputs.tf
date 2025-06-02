output "forwarding_rule_ip" {
  description = "The IP address of the regional TCP load balancer"
  value       = google_compute_forwarding_rule.k3s_forwarding_rule.ip_address
}
