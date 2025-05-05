locals {
  vms = { for vm in var.vm_config : vm.name => vm }
}

resource "aws_security_group" "default" {
  for_each = local.vms

  name = "${each.key}-sg"

  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${each.key}-sg"
  }
}

resource "aws_instance" "vm" {
  for_each = local.vms

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  vpc_security_group_ids = [aws_security_group.default[each.key].id]
  subnet_id = var.subnet_ids_by_name[each.value.subnet]
  associate_public_ip_address =  each.value.associate_public_ip_address
  tags                   = each.value.tags
}