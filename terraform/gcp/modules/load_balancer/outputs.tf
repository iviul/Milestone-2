output "forwarding_rule_ip" {
  description = "IP address of the forwarding rule"
  value       = google_compute_forwarding_rule.k3s_forwarding_rule.ip_address
}

output "target_pool" {
  description = "Details of the created target pool"
  value       = google_compute_target_pool.k3s_target_pool
}
