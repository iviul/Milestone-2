locals {
  config = jsondecode(file("${path.module}/config.json"))
}

module "network" {
  for_each = { for net in local.config.networks : net.network_name => net }
  source           = "./modules/network"
  vpc_name         = each.value.network_name
  subnet_name      = each.value.subnetwork_name
  subnet_cidr      = each.value.subnetwork_cidr
  region           = each.value.region
  allowed_ip_ranges = ["0.0.0.0/0"]
  ssh_allowed_ip_ranges = each.value.ports
}

module "db_instance" {
  for_each = { for db in local.config.dbs : db.db_name => db }
  source     = "./modules/db_instance"
  project_id = var.project_id
  region     = each.value.region
  instance_name = each.value.db_name
  database_version = each.value.database_version
  tier       = each.value.tier
  db_name    = each.value.db_name
  db_user    = each.value.user_name
  db_password = each.value.password
  private_network = module.network[each.value.private_network].vpc_network_self_link
  depends_on = [module.network]
}
