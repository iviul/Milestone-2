locals {
  cfg = jsondecode(file("${path.module}/../config.json"))
}

module "network" {
  source        = "../modules/network"
  networks_list = local.cfg["networks"]

}

module "security_group" {
  source        = "../modules/security_group"
  networks_list = local.cfg["networks"]
  network_self_links = module.network.network_self_links
}

module "vm" {
  source                = "../modules/vm"
  vms_list              = local.cfg["vms"]
  subnet_self_links_map = module.network.subnet_self_links

  depends_on = [
    module.network
  ]
}
