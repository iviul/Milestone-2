locals {
  config = jsondecode(file("${path.module}/../config-kuber.json"))
  config = jsondecode(file("${path.module}/../config-kuber.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  region                = local.fixed_region_map["gcp"]
  db_password           = "password"
  db_username           = "user"

  gcp_artifact_registry = one([
    for ar in local.config.artifact_registry : ar
    if ar.provider == "gcp"
  ])

  ssh_keys = local.config.project.keys

  service_account_email = local.config.project.service_account_email

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
  service_account_email = local.service_account_email 
}

resource "google_project_service" "monitoring" {
  service = "monitoring.googleapis.com"
  project = local.config.project.name
  disable_dependent_services  = true
}

module "monitoring" {
  source      = "./modules/monitoring"
  alert_email = local.config.monitoring.alert_email
  disk_usage_threshold                = local.config.monitoring.disk_usage_threshold
  memory_usage_threshold              = local.config.monitoring.memory_usage_threshold
  network_outbound_threshold          = local.config.monitoring.network_outbound_threshold
  cpu_usage_threshold                 = local.config.monitoring.cpu_usage_threshold
}

module "load_balancer" {
  source                    = "./modules/load_balancer"
  project_id                = local.config.project.name
  load_balancer_name        = local.load_balancer.name
  region                    = local.load_balancer.region
  zone                      = "europe-west3-a"               
  network                   = module.network.vpc_self_links["k3s-vpc"]
  instances                 = module.vm.non_bastion_instances_self_links

  ip_address                = local.load_balancer.ip_address
  load_balancer_port_range  = local.load_balancer.port_range
}

module "db_instance" {
  source            = "./modules/db_instance"
  project_id        = local.config.project.name
  region            = local.region
  databases         = local.config.databases
  private_networks  = module.network.vpc_self_links
  subnet_self_links = module.network.subnet_self_links_by_name
  depends_on        = [module.network]
  db_pass           = local.db_password
  db_username       = local.db_username
}
    
module "cloudflare_dns" {
  source               = "../shared_modules/cloudflare_dns"
  cloudflare_zone_id   = var.cloudflare_zone_id
  dns_records_config   = local.config.dns_records
  lb_dns_names         = module.load-balancer.lb_name_to_ip_map
  cloudflare_api_token = var.cloudflare_api_token
}
