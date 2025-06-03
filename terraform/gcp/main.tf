locals {
  config = jsondecode(file("${path.module}/../config-kuber.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  region   = local.fixed_region_map["gcp"]
  ssh_keys = local.config.project.keys

  load_balancer = {
    name       = "k3s-lb"
    region     = local.region
    ip_address = ""
    port_range = "6443"
  }
}

module "network" {
  source          = "./modules/network"
  project_id      = local.config.project.name
  region          = local.region
  networks        = local.config.network
  acls            = []
  security_groups = local.config.security_groups
}

module "vm" {
  source                = "./modules/vm"
  project_id            = local.config.project.name
  region                = local.region
  project_os            = local.config.project.os
  vm_instances          = local.config.vm_instances
  subnet_self_links_map = module.network.subnet_self_links_by_name
  ssh_keys              = local.ssh_keys
  depends_on            = [module.network]
}

module "load_balancer" {
  source                    = "./modules/load_balancer"
  load_balancer_name        = local.load_balancer.name
  region                    = local.load_balancer.region
  zone                      = "europe-west3-a"               
  network                   = "https://www.googleapis.com/compute/v1/projects/${local.config.project.name}/global/networks/lofty-memento-458508-i1-k3s-vpc-vpc"
  instances                 = module.vm.instances_self_links
  ip_address                = local.load_balancer.ip_address
  load_balancer_port_range  = local.load_balancer.port_range
}

resource "google_compute_firewall" "allow_lb_to_vm" {
  name    = "allow-lb-to-vm-6443"
  network = "https://www.googleapis.com/compute/v1/projects/${local.config.project.name}/global/networks/lofty-memento-458508-i1-k3s-vpc-vpc"

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [module.load_balancer.forwarding_rule_ip]

  target_tags = ["k3s-worker", "k3s-master"]

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  description = "Allow incoming traffic from load balancer IP on port 6443 to the VMs."

  # Use explicit depends_on to ensure proper ordering
  depends_on = [
    module.load_balancer
  ]
}
