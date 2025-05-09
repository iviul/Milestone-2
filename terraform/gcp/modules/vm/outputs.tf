output "created_vm_public_ips" {
  description = "Map of VM name → external IP"
  value       = { for k, v in google_compute_instance.vm: k => v.network_interface[0].access_config }
}
