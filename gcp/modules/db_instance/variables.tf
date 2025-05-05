variable "databases" {
  description = "List of database configurations"
  type = list(object({
    db_name          = string
    database_version = string
    region           = string
    tier             = string
    user_name        = string
    password         = string
    private_network  = string
  }))
}

variable "private_networks" {
  description = "Map of private network self-links"
  type = map(string)
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}
