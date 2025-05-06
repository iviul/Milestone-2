variable "networks" {
  description = "List of network configurations"
  type = list(object({
    network_name    = string
    subnetwork_name = string
    subnetwork_cidr = string
    region          = string
    ports           = list(string)
  }))
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for the network"
  type        = list(string)
}


variable "network_self_links" {
  description = "Maps of vpc networks"
  type        = map(string)
}
