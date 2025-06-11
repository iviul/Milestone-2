# data "google_secret_manager_secret_version_access" "db_username" {
#   secret  = "db_username"
#   version = "latest"
# }

# data "google_secret_manager_secret_version_access" "db_password" {
#   secret  = "db_pass"
#   version = "latest"
# }

locals {
  config = jsondecode(file("${path.module}/config-kuber.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  region      = local.fixed_region_map["gcp"]
  # db_username = data.google_secret_manager_secret_version_access.db_username.secret
  # db_password = data.google_secret_manager_secret_version_access.db_password.secret

  # gcp_artifact_registry = one([
  #   for ar in local.config.artifact_registry : ar
  #   if ar.provider == "gcp"
  # ])

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
  acls            = local.config.network[0].subnets
  security_groups = local.config.security_groups
  health_check_port = var.health_check_port
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

<<<<<<< HEAD
module "db_instance" {
  source            = "./modules/db-instance"
  project_id        = local.config.project.name
  region            = local.region
  databases         = local.config.databases
  private_networks  = module.network.vpc_self_links
  subnet_self_links = module.network.subnet_self_links_by_name
  depends_on        = [module.network]
  db_pass           = local.db_password
  db_username       = local.db_username
}

module "artifact-registry" {
  source                        = "./modules/artifact-registry"
  region                        = local.gcp_artifact_registry.region
  artifact_registry_id          = local.gcp_artifact_registry.name
  artifact_registry_description = local.gcp_artifact_registry.repository_type
  artifact_registry_format      = local.gcp_artifact_registry.format
}
=======
module "load_balancer" {
  source                    = "./modules/load_balancer"
  project_id                = local.config.project.name
  load_balancer_name        = local.load_balancer.name
  region                    = local.load_balancer.region
  zone                      = "europe-west3-a"               
  network                   = module.network.vpc_self_links["k3s-vpc"]
  instances                 = module.vm.instances_self_links
  ip_address                = local.load_balancer.ip_address
  load_balancer_port_range  = local.load_balancer.port_range
  health_check_port         = var.health_check_port
}

# module "db_instance" {
#   source            = "./modules/db_instance"
#   project_id        = local.config.project.name
#   region            = local.region
#   databases         = local.config.databases
#   private_networks  = module.network.vpc_self_links
#   subnet_self_links = module.network.subnet_self_links_by_name
#   depends_on        = [module.network]
#   db_pass           = local.db_password
#   db_username       = local.db_username
# }
>>>>>>> 83527c1e14ad7930f82b79aae018c083068f8f7c
