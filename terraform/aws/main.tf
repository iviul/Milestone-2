terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

module "network" {
  source   = "./modules/network"
  region   = var.region
  vpc_cidr = local.config.network.vpc_cidr
  subnets  = local.config.network.subnets
}