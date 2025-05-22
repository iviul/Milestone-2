locals {
  vms = { for vm in var.vms : vm.name => vm }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "vm" {
  for_each = local.vms

  ami                         = each.value.image
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_ids_by_vpc_subnet_name[each.value.network][each.value.subnet]
  associate_public_ip_address = each.value.subnet_data.public
  vpc_security_group_ids      = [for sg_name in each.value.security_groups : var.sg_ids_by_name[sg_name]]
  key_name                    = aws_key_pair.ssh-key.key_name
  iam_instance_profile        = each.value.iam_instance_profile_name != null ? each.value.iam_instance_profile_name : null
  tags = {
    Name = each.key
  }

  user_data = templatefile("${path.root}/scripts/setup_ssh.tpl", {
    ssh_keys = join("\n", var.ssh_keys)
  })
}

