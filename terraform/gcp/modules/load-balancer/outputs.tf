output "forwarding_rule_ip" {
  description = "Map of forwarding rule IP addresses by load balancer name."
  value       = { for k, fr in google_compute_forwarding_rule.k3s_forwarding_rule : k => fr.ip_address }
}

output "lb_name_to_ip_map" {
  value = {
    for lb in var.load_balancers :
    lb.name => google_compute_address.lb_static_ip[lb.name].address
  }
}