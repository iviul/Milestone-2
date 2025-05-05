variable "networks_list" {
  description = "List of network definitions from config.json"
  type = list(object({
    network_name    = string
    subnetwork_name = string
    subnetwork_cidr = string
    region          = string
    ports           = list(string)
  }))
}
