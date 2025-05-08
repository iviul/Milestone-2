locals {
  config = jsondecode(file("${path.module}/config.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  fixed_zone_suffixes = ["a", "b", "c"]

  fixed_os_image = {
    aws = { ubuntu = "ami-0129bfde49ddb0ed6" }
    gcp = { ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts" }
  }

  size_map = {
    aws = {
      small  = "t3.micro"
      medium = "t3.medium"
      large  = "t3.large"
    },
    gcp = {
      small  = "e2-micro"
      medium = "e2-standard-2"
      large  = "e2-standard-4"
    }
  }

  ################################################################################
  # Operating system selected in the JSON   →  "ubuntu", "debian", etc. and for Dima its terraform username
  os = local.config.project.os

  # Team-fixed region for the chosen provider
  #   aws => eu-central-1
  #   gcp => europe-west3
  region = local.fixed_region_map[var.cloud_provider]

  # Map: subnet-name  ➜  full subnet object
  # Makes it easy to look up cidr / “public” flag by name
  # subnets_by_name = {
  #   for s in local.config.network.subnets : s.name => s
  # }

  # # Enriched list of VM objects.
  # # For every vm in JSON we merge:
  # #   • subnet_data   – the full subnet record it lives in
  # #   • instance_type – resolved from `size_map` for the provider
  # #   • image         – fixed OS image for the provider/OS
  # vms = [
  #   for vm in local.config.vm_instances :
  #   merge(vm, {
  #     subnet_data   = local.subnets_by_name[vm.subnet],
  #     instance_type = local.size_map[var.cloud_provider][vm.size],
  #     image         = local.fixed_os_image[var.cloud_provider][local.os]
  #   })
  # ]

  # # Same enrichment pattern but for databases
  # databases = [
  #   for db in local.config.databases :
  #   merge(db, {
  #     subnet_data   = local.subnets_by_name[db.subnet],
  #     instance_type = local.size_map[var.cloud_provider][db.size]
  #   })
  # ]

  # # Raw shortcuts
  # security_groups  = local.config.security_groups
  # networks_by_name = { for n in local.config.networks : n.name => n.cidr }

  # # Helper map: SG name  ➜  list of resources it is attached to
  # resource_to_sg = {
  #   for sg in local.security_groups :
  #   sg.name => sg.attach_to
  # }

  # # Inverse helper: resource name  ➜  list of SG names attached to it.
  # #   • concat() joins the VM-names list with the DB-names list.
  # #   • inner for...if returns only SGs that contain this resource.
  # sg_for_resource = {
  #   for res in concat(
  #     local.vms[*].name,
  #     local.databases[*].name
  #   ) :
  #   res => [
  #     for sg in local.security_groups :
  #     sg.name if contains(sg.attach_to, res)
  #   ]
  # }
}