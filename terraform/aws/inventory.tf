locals {
  db_name = "maindb" # Default database name

  inventory = templatefile("${path.module}/../inventory.tpl", {
    private_ips = module.vms.private_ips
    bastion_ip       = module.vms.public_ips["bastion"]
    public_ips       = module.vms.public_ips
    private_key_path = var.private_key_path
    lb_dns_names     = module.load_balancers.lb_dns_names

    db_host     = module.db.db_hosts[local.db_name]
    db_user     = module.db.db_users[local.db_name]
    db_password = module.db.db_passwords[local.db_name]
    db_port     = module.db.db_ports[local.db_name]
    db_name     = module.db.db_names[local.db_name]

    redis_host = module.vms.private_ips["redis"]
    redis_port = module.vms.ports["redis"]
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = "${path.module}/../../ansible/inventory/inventory.ini"
}
