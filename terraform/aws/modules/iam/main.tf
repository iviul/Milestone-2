locals {
  iam = { for ir in var.iam : ir.name => ir }
}

resource "aws_iam_role_policy" "policy" {
  for_each = local.iam

  name = "${each.value.name}-policy"
  role = aws_iam_role.role[each.key].id

  policy = jsonencode(each.value.role_policy)
}

resource "aws_iam_role" "role" {
  for_each = local.iam

  name               = "${each.value.name}-role"
  assume_role_policy = jsonencode(each.value.trust_policy)
}

resource "aws_iam_instance_profile" "profile" {
  for_each = local.iam

  name = each.value.name
  role = aws_iam_role.role[each.key].name
}