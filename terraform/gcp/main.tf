locals {
  config = jsondecode(file("${path.module}/../config-kuber.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  region        = local.fixed_region_map["gcp"]
  db_password   = "password"
  db_username   = "user"

  gcp_artifact_registry = one([
    for ar in local.config.artifact_registry : ar
    if ar.provider == "gcp"
  ])

  ssh_keys = local.config.project.keys
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

module "db-instance" {
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

module "load-balancer" {
  source         = "./modules/load-balancer"
  project_id     = local.config.project.name
  region         = local.region
  zone           = "europe-west3-a"
  network = module.network.vpc_self_links[local.config.load_balancers[0].vpc]
  instances      = module.vm.non_bastion_instances_self_links
  
  load_balancers = local.config.load_balancers 
}