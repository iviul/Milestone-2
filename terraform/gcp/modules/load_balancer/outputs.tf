output "forwarding_rule_ip" {
  description = "The forwarding rule IP address."
  value       = google_compute_forwarding_rule.lb.ip_address
}
