locals {
  dbs = { for db in var.db_config : db.identifier => db}
}

resource "aws_db_subnet_group" "my_db" {
  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "database" {
    for_each = local.dbs
    
  allocated_storage    = each.value.allocated_storage
  db_name              = each.value.db_name
  identifier           = each.value.identifier
  engine               = each.value.engine
  instance_class       = each.value.instance_class
  username             = each.value.username
  password             = each.value.password
  parameter_group_name = each.value.parameter_group_name
  publicly_accessible  = each.value.publicly_accessible
  skip_final_snapshot  = each.value.skip_final_snapshot
  port                 = each.value.port
  db_subnet_group_name = aws_db_subnet_group.my_db.name
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = each.value.tags
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    secret_id = aws_db_instance.database.identifier
  }

  byte_length = 8
}

resource "aws_secretsmanager_secret" "db_secret" {
  for_each = local.dbs

  name = "db-credentials-${each.value.identifier}-${random_id.server.hex}"
  description = "Credentials for DB ${each.value.identifier}-${random_id.server.hex}"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  for_each = aws_secretsmanager_secret.db_secret

  secret_id     = each.value.id
  secret_string = jsonencode({
    DB_USER = aws_db_instance.database[each.key].username
    DB_HOST = aws_db_instance.database[each.key].address
    DB_NAME = aws_db_instance.database[each.key].db_name
    DB_PASS = aws_db_instance.database[each.key].password
    DB_PORT = aws_db_instance.database[each.key].port
  })
}