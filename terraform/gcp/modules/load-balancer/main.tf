# Instance Group (Unmanaged)
resource "google_compute_instance_group" "k3s_group" {
  name      = "${var.load_balancer_name}-ig"
  zone      = var.zone
  instances = var.instances
  network   = var.network

  named_port {
    name = "k3s"
    port = var.health_check_port
  }
}

# Health Check
resource "google_compute_health_check" "tcp_hc" {
  name = "${var.load_balancer_name}-tcp-hc"

  tcp_health_check {
    port = var.health_check_port
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Regional Health Check
resource "google_compute_region_health_check" "tcp_hc" {
  name   = "${var.load_balancer_name}-tcp-hc"
  region = var.region

  tcp_health_check {
    port = var.health_check_port // use the same port as the instance group
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Backend Service for Network Load Balancer
resource "google_compute_region_backend_service" "k3s_backend" {
  name                  = "${var.load_balancer_name}-backend"
  region                = var.region
  protocol              = "TCP"
  port_name             = "k3s"
  health_checks         = [google_compute_region_health_check.tcp_hc.self_link]
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL"

  backend {
    group          = google_compute_instance_group.k3s_group.self_link
    balancing_mode = "CONNECTION"
    #max_connections = 100
  }
}

# Global static IP (if needed)
resource "google_compute_address" "lb_static_ip" {
  name   = "${var.load_balancer_name}-static-ip"
  region = var.region
}

# Forwarding Rule for Network Load Balancer
resource "google_compute_forwarding_rule" "k3s_forwarding_rule" {
  name                  = "${var.load_balancer_name}-fr"
  ip_address            = google_compute_address.lb_static_ip.address
  ip_protocol           = "TCP"
  port_range            = var.load_balancer_port_range
  backend_service       = google_compute_region_backend_service.k3s_backend.self_link
  load_balancing_scheme = "EXTERNAL"
  region                = var.region
}

resource "google_compute_firewall" "allow_lb_to_vm" {
  name    = "allow-lb-to-vm-6443"
  network = var.network

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [google_compute_forwarding_rule.k3s_forwarding_rule.ip_address]

  target_tags = ["k3s-worker", "k3s-master"] 

  allow {
    protocol = "tcp"
    ports    = [tostring(var.health_check_port)]
  }

  description = "Allow incoming traffic from load balancer IP on port 6443 to the VMs."

  depends_on = [
    google_compute_forwarding_rule.k3s_forwarding_rule
  ]
}
