output "public_ips" {
  value = { for k, vm in aws_instance.vm : k => vm.public_ip }
}

output "private_ips" {
  value = { for k, vm in aws_instance.vm : k => vm.private_ip }
}

output "ports" {
  value = { for vm_name, vm in local.vms : vm_name => vm.port }
}