output "forwarding_rule_ip" {
  description = "Map of forwarding rule IP addresses by load balancer name."
  value       = { for k, fr in google_compute_forwarding_rule.k3s_forwarding_rule : k => fr.ip_address }
}
