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

# output "sg_keys" {
#   value = module.network.sg_keys
# }

# output "all_resources" {
#   value = module.network.all_resources
# }

output "subnets" {
  value = module.network.subnet_ids
}

# module "db" {
#   source = "./modules/database"
#   config = local.Config.databases
#   # subnet_ids = [ module.network.subnet_id_public, module.network.subnet_id_private, module.network.subnet_id_db ]
#   subnet_ids = module.network.subnet_ids
#   vpc_security_group_ids  = [ module.network.vpc_security_group_ids_rds ]
# }