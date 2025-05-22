output "sg_ids_by_name" {
  value = {
    for name, sg in aws_security_group.all : name => sg.id
  }
}