locals {
  inventory = templatefile("${path.module}/../inventory.tpl", {
    private_ips = module.vms.private_ips
    bastion_ip  = module.vms.public_ips["bastion"]
    home_dir     = var.home_dir
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}

