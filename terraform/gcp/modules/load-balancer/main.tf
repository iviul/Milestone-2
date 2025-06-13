# Instance Group (Unmanaged)
resource "google_compute_instance_group" "k3s_group" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name      = "${each.value.name}-ig"
  zone      = var.zone
  instances = each.value.instances
  network   = var.network

  named_port {
    name = each.value.port_name
    port = each.value.health_check_port
  }
}

# Health Check
resource "google_compute_health_check" "tcp_hc" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name = "${each.value.name}-tcp-hc"

  tcp_health_check {
    port = each.value.health_check_port
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Regional Health Check
resource "google_compute_region_health_check" "tcp_hc" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name   = "${each.value.name}-tcp-hc"
  region = var.region

  tcp_health_check {
    port = each.value.health_check_port
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Backend Service for Network Load Balancer
resource "google_compute_region_backend_service" "k3s_backend" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name                  = "${each.value.name}-backend"
  region                = var.region
  protocol              = "TCP"
  port_name             = each.value.port_name
  health_checks         = [google_compute_region_health_check.tcp_hc[each.key].self_link]
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL"

  backend {
    group          = google_compute_instance_group.k3s_group[each.key].self_link
    balancing_mode = "CONNECTION"
  }
}

# Global static IP (if needed)
resource "google_compute_address" "lb_static_ip" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name   = "${each.value.name}-static-ip"
  region = var.region
}

# Forwarding Rule for Network Load Balancer
resource "google_compute_forwarding_rule" "k3s_forwarding_rule" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name                  = "${each.value.name}-fr"
  ip_address            = google_compute_address.lb_static_ip[each.key].address
  ip_protocol           = "TCP"
  port_range            = each.value.port_range
  backend_service       = google_compute_region_backend_service.k3s_backend[each.key].self_link
  load_balancing_scheme = "EXTERNAL"
  region                = var.region
}

resource "google_compute_firewall" "allow_lb_to_vm" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name    = "allow-lb-to-vm-${each.value.port_range}"
  network = var.network

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [google_compute_forwarding_rule.k3s_forwarding_rule[each.key].ip_address]

  target_tags = each.value.target_tags

  allow {
    protocol = "tcp"
    ports    = [tostring(each.value.health_check_port)]
  }

  description = "Allow incoming traffic from load balancer IP on port ${each.value.port_range} to the VMs."

  depends_on = [
    google_compute_forwarding_rule.k3s_forwarding_rule
  ]
}
