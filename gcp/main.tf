locals {
  config = jsondecode(file("${path.module}/../config.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  fixed_zone_suffixes = ["a", "b", "c"]

  region = local.fixed_region_map["gcp"]

}

# module "network" {
#   source            = "./modules/network"
#   networks          = local.config.networks
#   allowed_ip_ranges = ["0.0.0.0/0"]
#   network_self_links = module.network.network_self_links
# }


module "network" {
  source           = "./modules/network"
  project_id       = local.config.project.project_id
  region           = local.region
  vpc_cidr         = local.config.network.vpc_cidr
  subnets          = local.config.network.subnets
  acls             = local.config.networks
  security_groups  = local.config.security_groups
}


module "vm" {
  source                  = "./modules/vm"
  project_id              = local.config.project.project_id
  region                  = local.region
  project_os              = local.config.project.os
  vm_instances            = local.config.vm_instances
  subnet_self_links_map   = module.network.subnet_self_links

  depends_on = [ module.network ]
}

# module "db_instance" {
#   source           = "./modules/db_instance"
#   project_id       = var.project_id
#   databases        = local.config.dbs
#   private_networks = { for net in local.config.networks: net.network_name => module.network.network_self_links[net.network_name] }
#   depends_on       = [module.network]
# }
