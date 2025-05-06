terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

module "network" {
  source = "./modules/network"

  region = local.fixed_region_map
  vpcs   = local.config.network
}
module "vms" {
  source             = "./modules/vms"
  vms                = local.vms
  vpc_id             = module.network.vpc_id
  subnet_ids_by_name = module.network.subnet_ids_by_name
}
