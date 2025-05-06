# output "subnet_id_public" {
#   value = aws_subnet.public.id
# }

# output "subnet_id_private" {
#   value = aws_subnet.private.id
# }

# output "subnet_id_db" {
#   value = aws_subnet.db.id
# }

# output "vpc_security_group_ids_instances" {
#   value = aws_security_group.instances.id
# }

# output "vpc_security_group_ids_rds" {
#   value = aws_security_group.rds_sg.id
# }

output "sg_keys" {
  value = keys(aws_security_group.sg)
}