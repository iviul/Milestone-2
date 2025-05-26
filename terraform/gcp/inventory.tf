locals {
  db_name = "maindb" # Default database name

  inventory = templatefile("${path.module}/../inventory.tpl", {
    private_ips      = module.vm.private_ips
    private_key_path = var.private_key_path
    # bastion_ip = module.vm.private_ips["bastion"]



    # redis_host = module.vm.private_ips["redis"]
    # redis_port = module.vm.ports["redis"]
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}
