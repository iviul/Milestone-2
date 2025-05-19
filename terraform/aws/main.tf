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
  source           = "./modules/security_groups"
  security_groups  = local.security_groups
  networks_by_name = local.networks_by_name
  vpc_ids_by_name  = module.network.vpc_ids_by_name
}

module "vms" {
  source                        = "./modules/vms"
  vms                           = local.vms
  sg_ids_by_name                = module.security_groups.sg_ids_by_name
  subnet_ids_by_vpc_subnet_name = module.network.subnet_ids_by_vpc_subnet_name
}

module "db" {
  source = "./modules/database"

  config                 = local.config
  subnets                = module.network.subnets
  vpc_security_group_ids = module.security_groups.sg_ids_by_name
}

module "iam" {
  source = "./modules/iam"

  iam = local.config.iam.aws
}