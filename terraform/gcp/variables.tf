variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "lofty-memento-458508-i1" #change to your project id
  
}
variable "db_password" {
  description = "The GCP project ID"
  
}

variable "region" {
    description = "Region for the network"
    type        = string
    default     = "europe-central2"
}

