terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_user
}

module "network" {
  source = "./modules/network"

  region = local.fixed_region_map
  vpcs   = local.config.network
}

module "security_groups" {
  source           = "./modules/security-groups"
  security_groups  = local.security_groups
  networks_by_name = local.networks_by_name
  vpc_ids_by_name  = module.network.vpc_ids_by_name
}

module "target_groups" {
  source = "./modules/target-groups"

  target_groups   = local.target_groups
  vpc_ids_by_name = module.network.vpc_ids_by_name
  vm_ids_by_name  = module.vms.vm_ids_by_name
}

module "load_balancers" {
  source = "./modules/load-balancer"

  load_balancers  = local.load_balancers
  subnets         = module.network.subnets
  security_groups = module.security_groups.sg_ids_by_name
}

module "listeners" {
  source = "./modules/listener"

  listeners       = local.listeners
  tg_arns_by_name = module.target_groups.tg_arns_by_name
  lb_arns_by_name = module.load_balancers.lb_arns_by_name
}

module "vms" {
  source                        = "./modules/vms"
  vms                           = local.vms
  ssh_keys                      = local.ssh_keys
  sg_ids_by_name                = module.security_groups.sg_ids_by_name
  subnet_ids_by_vpc_subnet_name = module.network.subnet_ids_by_vpc_subnet_name
}

module "db" {
  source = "./modules/database"

  config                 = local.config
  subnets                = module.network.subnets
  vpc_security_group_ids = module.security_groups.sg_ids_by_name
}

module "cloudflare_dns" {
  source               = "../shared_modules/cloudflare_dns"
  cloudflare_zone_id   = var.cloudflare_zone_id
  dns_records_config   = local.config.dns_records
  resource_dns_map     = module.load_balancers.lb_dns_names
  cloudflare_api_token = var.cloudflare_api_token
}

module "iam" {
  source = "./modules/iam"

  iam = local.config.iam.aws
}

module "registry" {
  source = "./modules/registry"

  config = local.config
}