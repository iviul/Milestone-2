output "forwarding_rule_ip" {
  description = "The forwarding rule IP address."
  value       = google_compute_forwarding_rule.k3s_forwarding_rule.ip_address
}
