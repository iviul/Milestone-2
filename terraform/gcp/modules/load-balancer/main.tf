resource "google_compute_instance_group" "k3s_group" {
  name      = "k3s-shared-ig"
  zone      = var.zone
  instances = var.instances
  network   = var.network

  dynamic "named_port" {
    for_each = var.load_balancers
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

resource "google_compute_region_health_check" "tcp_hc" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  name     = "${each.value.name}-tcp-hc"
  region   = var.region

  tcp_health_check {
    port = each.value.port
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

resource "google_compute_region_backend_service" "k3s_backend" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  
  name                  = "${each.value.name}-backend"
  region                = var.region
  protocol              = each.value.protocol
  port_name             = each.value.name
  health_checks         = [google_compute_region_health_check.tcp_hc[each.key].self_link]
  timeout_sec           = 10
  load_balancing_scheme = each.value.internal ? "INTERNAL" : "EXTERNAL"

  backend {
    group          = google_compute_instance_group.k3s_group.self_link
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_address" "lb_static_ip" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  
  name         = "${each.value.name}-static-ip"
  region       = var.region
  address_type = each.value.internal ? "INTERNAL" : "EXTERNAL"
}

resource "google_compute_forwarding_rule" "k3s_forwarding_rule" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  
  name                  = "${each.value.name}-fr"
  ip_address            = google_compute_address.lb_static_ip[each.key].address
  ip_protocol           = each.value.protocol
  port_range            = tostring(each.value.port)
  backend_service       = google_compute_region_backend_service.k3s_backend[each.key].self_link
  load_balancing_scheme = each.value.internal ? "INTERNAL" : "EXTERNAL"
  region                = var.region
}

resource "google_compute_firewall" "allow_lb_to_vm" {
  for_each = { for lb in var.load_balancers : lb.name => lb }
  
  name    = "allow-lb-to-vm-${each.value.port}"
  network = var.network

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [google_compute_forwarding_rule.k3s_forwarding_rule[each.key].ip_address]

  target_tags = each.value.target_tags

  allow {
    protocol = lower(each.value.protocol)
    ports    = [tostring(each.value.port)]
  }
  
  description = "Allow incoming traffic from load balancer IP on port ${each.value.port} to the VMs."
  depends_on = [
    google_compute_forwarding_rule.k3s_forwarding_rule
  ]

}