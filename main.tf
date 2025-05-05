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
  # vmConfig = jsondecode(file("${path.module}/files/vms.json"))
  dbConfig = jsondecode(file("${path.module}/files/dbs.json"))
}

module "network" {
  source = "./modules/network"

  assign_public_ip = true
}

# module "test" {
#   source = "./modules/test"
#   vm_config = local.vmConfig.vms
# }

module "db" {
  source = "./modules/database"
  db_config = local.dbConfig.dbs
  subnet_ids = [ module.network.subnet_id_public, module.network.subnet_id_private, module.network.subnet_id_db ]
  vpc_security_group_ids  = [ module.network.vpc_security_group_ids_rds ]
}