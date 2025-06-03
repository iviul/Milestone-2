locals {
  config = jsondecode(file("${path.module}/../config.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  fixed_zone_suffixes = ["a", "b", "c"]

  fixed_os_image = {
    aws = { ubuntu = "ami-03250b0e01c28d196" }
    gcp = { ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts" }
  }

  size_map = {
    aws = {
      small  = "t3.small"
      medium = "t3.medium"
      large  = "t3.large"
    },
    gcp = {
      small  = "e2-micro"
      medium = "e2-standard-2"
      large  = "e2-standard-4"
    }
  }

  os = local.config.project.os

  region = local.fixed_region_map[var.cloud_provider]

  subnets_by_vpc_and_name = {
    for vpc in local.config.network : vpc.name => {
      for subnet in vpc.subnets : subnet.name => subnet
    }
  }

  ssh_keys = local.config.project.keys

  vms = [
    for vm in local.config.vm_instances :
    merge(vm, {
      subnet_data   = local.subnets_by_vpc_and_name[vm.network][vm.subnet],
      instance_type = local.size_map[var.cloud_provider][vm.size],
      image         = local.fixed_os_image[var.cloud_provider][local.os],
      ssh_keys      = local.ssh_keys
    })
  ]

  security_groups  = local.config.security_groups
  networks_by_name = { for n in local.config.networks : n.name => n.cidr }

  target_groups  = local.config.target_groups
  listeners      = local.config.listeners
  load_balancers = local.config.load_balancers
}