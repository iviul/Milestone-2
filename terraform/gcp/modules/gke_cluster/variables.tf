variable "clusters" {
  description = "Map of GKE clusters to create"
  type = map(object({
    name               = string
    location           = string
    network            = string
    subnetwork         = string
    initial_node_count = number
    node_pools = optional(list(object({
      name           = string
      machine_type   = string
      min_node_count = number
      max_node_count = number
      disk_size_gb   = optional(number)
      oauth_scopes   = optional(list(string))
      auto_upgrade   = optional(bool)
      auto_repair    = optional(bool)
    })), [])
    authorized_networks = list(object({
      cidr_block   = string
      display_name = string
    }))
    private_cluster    = bool
    kubernetes_version = string
  }))
}

variable "vpc_self_links" {
  description = "Map of network name to VPC self_link"
  type        = map(string)
}

variable "subnet_self_links" {
  description = "Map from network-subnet name to self_link"
  type        = map(string)
}