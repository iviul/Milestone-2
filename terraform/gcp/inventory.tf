locals {
  inventory = templatefile("${path.module}/../inventory.tpl", {
    public_ips  = module.vm.public_ips
    private_ips = module.vm.private_ips
    bastion_ip  = module.vm.public_ips["bastion"]
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}

