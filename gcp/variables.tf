variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "lofty-memento-458508-i1"
}

variable "region" {
    description = "Region for the network"
    type        = string
    default     = "europe-central2"
}

variable "zone" {
    description = "Zone for the network"
    type        = string
    default     = "europe-central2-a"
}

variable "name" {
    description = "Name of the VPC"
    type        = string
    default = "postgres-vpc"
}

variable "db_password" {
  description = "The password for the PostgreSQL database user"
  type        = string
  sensitive = true
  
}
