variable "vms_list" {
  description = "List of VM definitions from config.json"
  type = list(object({
    vm_name      = string
    machine_type = string
    zone         = string
    image        = string
    network      = string
    subnetwork   = string
    metadata     = map(string)
    tags         = list(string)
  }))
}

variable "subnet_self_links_map" {
  description = "Map of subnetwork self_links by network name"
  type        = map(string)
}
