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

output "non_bastion_instances_self_links" {
  description = "Self links of instances without bastion tag"
  value = [
    for inst in google_compute_instance.vm :
    inst.self_link if !contains(inst.tags, "bastion")
  ]
}

output "bastion_instances_self_links" {
  description = "Self links of instances with bastion tag"
  value = [
    for inst in google_compute_instance.vm :
    inst.self_link if contains(inst.tags, "bastion")
  ]
}

output "instances_self_links" {
  value = [
    for inst in google_compute_instance.vm :
    inst.self_link
  ]
}


