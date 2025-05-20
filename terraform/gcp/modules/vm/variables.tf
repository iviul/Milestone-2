variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}

variable "project_os" {
  type        = string
  description = "Key for OS lookup (e.g. ubuntu)"
}

variable "vm_instances" {
  type = list(object({
    name            = string
    network         = string
    size            = string
    zone            = string
    subnet          = string
    tags            = set(string)
    port            = number
    security_groups = optional(list(string), [])
    public_ip       = bool
  }))
  description = "List of VMs (from config.json)"
}

variable "subnet_self_links_map" {
  type        = map(string)
  description = "Map of subnet name → self_link (from network module)"
}

variable "ssh_keys" {
  description = "SSH public keys"
}
