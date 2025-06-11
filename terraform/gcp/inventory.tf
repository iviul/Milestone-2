locals {
  db_name = "maindb" # Default database name

   inventory = templatefile("${path.module}/../inventory.tpl", {
    private_ips      = module.vm.private_ips
    private_key_path = var.private_key_path
    public_ips      = module.vm.public_ips
    vm_public_ips        = module.vm.public_ips
    db_private     = module.db_instance.db_hosts[local.db_name]
    db_user     = module.db_instance.db_users[local.db_name]
    db_password = module.db_instance.db_passwords[local.db_name]
    db_port     = module.db_instance.db_ports[local.db_name]
    db_name     = module.db_instance.db_names[local.db_name]

    db_host     = module.db-instance.db_hosts[local.db_name]
    db_user     = module.db-instance.db_users[local.db_name]
    db_password = module.db-instance.db_passwords[local.db_name]
    db_port     = module.db-instance.db_ports[local.db_name]
    db_name     = module.db-instance.db_names[local.db_name]

    # redis_host = module.vm.private_ips["redis"]
    # redis_port = module.vm.ports["redis"]
   })
 }

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}
