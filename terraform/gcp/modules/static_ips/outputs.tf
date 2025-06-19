output "ip_addresses" {
  description = "Map of IP name to reserved address"
  value = merge(
    { for k, v in google_compute_global_address.static_global_ip : k => v.address },
    { for k, v in google_compute_address.static_regional_ip : k => v.address }
  )
}

output "ip_self_links" {
  description = "Map of IP name to self_link"
  value = merge(
    { for k, v in google_compute_global_address.static_global_ip : k => v.self_link },
    { for k, v in google_compute_address.static_regional_ip : k => v.self_link }
  )
}