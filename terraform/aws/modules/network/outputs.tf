output "subnet_ids" {
  description = "Map of subnet keys to their IDs and attributes"
  value = { for k, subnet in aws_subnet.subnets : k => {
    # name = subnet.tags["Name"]  # Assuming 'Name' is set in tags
    id   = subnet.id
    zone = subnet.availability_zone
    }
  }
}

output "subnets" {
  value = local.subnets
}
