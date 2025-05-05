output "vm_external_ip" {
  value = { for k, v in google_compute_instance.vm_instance : k => v.network_interface[0].access_config[0] }
}