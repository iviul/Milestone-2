locals {
  config = jsondecode(file("${path.module}/config.json"))
}

module "network" {
  source            = "./modules/network"
  networks          = local.config.networks
  allowed_ip_ranges = ["0.0.0.0/0"]
}

module "db_instance" {
  source           = "./modules/db_instance"
  project_id       = var.project_id
  databases        = local.config.dbs
  private_networks = { for net in local.config.networks : net.network_name => module.network.network_self_links[net.network_name] }
  depends_on       = [module.network]
}
