output "public_ips" {
  description = "Map of VM name → public IP (or empty string)"
  value = {
    for name, vm in google_compute_instance.vm :
    name => (
      try(vm.network_interface[0].access_config[0].nat_ip, "")
    )
  }
}

output "private_ips" {
  description = "Map of VM name → private IP"
  value = {
    for name, vm in google_compute_instance.vm :
    name => vm.network_interface[0].network_ip
  }
}

output "ports" {
  value = {
    for vm in var.vm_instances : vm.name => vm.port
  }
}
