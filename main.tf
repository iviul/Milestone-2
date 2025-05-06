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
  Config = jsondecode(file("${path.module}/files/config.json"))
}

module "network" {
  source = "./modules/network"
  vpcs = local.Config.network

  assign_public_ip = true
}

output "sg_keys" {
  value = module.network.sg_keys
}

# module "test" {
#   source = "./modules/test"
#   vm_config = local.vmConfig.vms
# }

# module "db" {
#   source = "./modules/database"
#   config = local.Config.dbs
#   subnet_ids = [ module.network.subnet_id_public, module.network.subnet_id_private, module.network.subnet_id_db ]
#   vpc_security_group_ids  = [ module.network.vpc_security_group_ids_rds ]
# }