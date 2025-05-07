locals {
  dbs = { for db in var.config.databases : db.name => {
    # DB conf
    identifier             = db.name
    engine                 = db.type
    port                   = db.port
    allocated_storage      = local.size_map.aws[db.size].storage
    instance_class         = local.size_map.aws[db.size].instance_class
    availability_zone      = db.zone
    vpc_security_group_ids = db.security_groups
    tags                   = { Name : db.name }
    }
  }

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  size_map = {
    aws = {
      small  = {
        storage = 20
        instance_class = "db.t4g.micro"
      }
      medium = {
        storage = 30
        instance_class = "db.t4g.micro"
      }
      large  = {
        storage = 40
        instance_class = "db.t4g.micro"
      }
    }
  }

  dbs_without_secret = {
    for id, check in data.external.check_secret_exists :
    id => local.dbs[id] if check.result.exists == "false"
  }
}

# Try to read existing secrets using a script
data "external" "check_secret_exists" {
  for_each = local.dbs

  program = ["bash", "${path.root}/scripts/check-secret.sh", each.key]
}

# Create missing secrets
resource "aws_secretsmanager_secret" "db_secret" {
  for_each = local.dbs_without_secret

  name        = "db-credentials-${each.value.identifier}"
  description = "Credentials for DB ${each.value.identifier}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  for_each = aws_secretsmanager_secret.db_secret

  secret_id = each.value.id
  secret_string = jsonencode({
    DB_USER = aws_db_instance.database[each.key].username
    DB_HOST = aws_db_instance.database[each.key].address
    DB_NAME = aws_db_instance.database[each.key].db_name
    DB_PASS = aws_db_instance.database[each.key].password
    DB_PORT = aws_db_instance.database[each.key].port
  })
}

resource "aws_db_subnet_group" "my_db" {
  for_each = local.dbs

  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "database" {
  for_each = local.dbs

  allocated_storage      = each.value.allocated_storage
  identifier             = each.value.identifier
  engine                 = each.value.engine
  instance_class         = each.value.instance_class
  db_name                = each.value.identifier
  username               = "username"
  password               = random_password.db_password[each.key].result
  parameter_group_name   = aws_db_parameter_group.default[each.key].name
  publicly_accessible    = true # For testing
  skip_final_snapshot    = true
  port                   = each.value.port
  db_subnet_group_name   = 
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = each.value.tags
}

resource "random_password" "db_password" {
  for_each = local.dbs

  length      = 16       # Length of the password
  special     = false    # Exclude special characters (set to `true` if needed)
  min_upper   = 1        # Minimum uppercase letters
  min_lower   = 1        # Minimum lowercase letters
  min_numeric = 1        # Minimum numbers
}

resource "aws_db_parameter_group" "default" {
  for_each = local.dbs

  name   = "rds-pg"
  family = "postgres14"
}