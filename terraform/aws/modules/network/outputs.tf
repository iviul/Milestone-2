output "subnets" {
  description = "Map of subnet keys to their IDs and attributes"
  value = { for k, subnet in aws_subnet.subnets : k => {
    id   = subnet.id
    zone = subnet.availability_zone
    }
  }
}

output "vpc_ids_by_name" {
  description = "Map of VPC keys to their IDs"
  value       = { for name, vpc in aws_vpc.terraform : name => vpc.id }
}

output "subnet_ids_by_vpc_subnet_name" {
  description = "Map of vpc and subnet names to subnet IDs"
  value = {
    for vpc_name, vpc in aws_vpc.terraform : vpc_name => {
      for subnet_key, subnet in local.subnets : subnet.name => aws_subnet.subnets[subnet_key].id
    }
  }
}
