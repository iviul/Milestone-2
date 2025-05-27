resource "google_compute_http_health_check" "hc" {
  name               = "${var.load_balancer_name}-hc"
  request_path       = "/"
  port               = var.health_check_port
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
}

resource "google_compute_target_pool" "k3s_target_pool" {
  name         = "${var.load_balancer_name}-pool"
  region       = var.region
  instances    = var.instances
  health_checks = [google_compute_http_health_check.hc.self_link]
}

resource "google_compute_forwarding_rule" "k3s_forwarding_rule" {
  name                  = "${var.load_balancer_name}-fr"
  region                = var.region
  target                = google_compute_target_pool.k3s_target_pool.self_link
  port_range            = var.load_balancer_port_range
  ip_address            = var.ip_address != "" ? var.ip_address : null
}
