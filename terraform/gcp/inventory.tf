locals {
  db_name = "maindb" # Default database name

  inventory = templatefile("${path.module}/../inventory.tpl", {
    private_ips      = module.vm.private_ips
    private_key_path = var.private_key_path

    db_host     = module.db-instance.db_hosts[local.db_name]
    db_user     = module.db-instance.db_users[local.db_name]
    db_password = module.db-instance.db_passwords[local.db_name]
    db_port     = module.db-instance.db_ports[local.db_name]
    db_name     = module.db-instance.db_names[local.db_name]

#    lb_ips      = module.load-balancer.lb_name_to_ip_map

    static_ips  = module.static_ips.ip_addresses

  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}
