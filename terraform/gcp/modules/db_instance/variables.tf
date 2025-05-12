variable "databases" {
  description = "List of database configurations"
  type = list(object({
    name             = string
    network          = string
    type             = string
    version          = string
    size             = string
    zone             = list(string)
    subnets          = list(string)
    port             = number
    security_groups  = list(string)
    region           = optional(string)
  }))
}

variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}

variable "db_pass" {
}

variable "db_username" {
}
