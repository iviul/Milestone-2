variable "databases" {
  description = "List of database configurations"
  type = list(object({
    name            = string
    network         = string
    type            = string
    version         = string
    size            = string
    zone            = list(string)
    subnets         = list(string)
    port            = number
    security_groups = list(string)
    region          = optional(string)
    secondary_zone  = optional(string)
  }))
}

variable "private_networks" {
  description = "Map of network name to VPC self-link"
  type        = map(string)
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "subnet_self_links" {
  description = "Map of subnet name to self-link"
  type        = map(string)
}

variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}

variable "db_pass" {
}

variable "db_username" {
}
