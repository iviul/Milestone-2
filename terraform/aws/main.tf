terraform {

  required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  Config = jsondecode(file("${path.module}/files/prod_config.json"))
}

module "network" {
  source = "./modules/network"
  vpcs = local.Config.network
}

module "db" {
  source = "./modules/database"
  config = local.Config.databases
  subnets = module.network.subnets
  # vpc_security_group_ids  = [ module.network.vpc_security_group_ids_rds ]
}