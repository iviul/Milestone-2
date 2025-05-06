output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids_by_name" {
  value = { for name, subnet in aws_subnet.subnets : name => subnet.id }
}
