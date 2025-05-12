locals {
  inventory = templatefile("${path.module}/../inventory.tpl", {
    public_ips  = module.vms.public_ips
    private_ips = module.vms.private_ips
    bastion_ip  = module.vms.public_ips["bastion"]
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}

