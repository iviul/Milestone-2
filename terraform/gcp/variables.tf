variable "project_id" {
  description = "The GCP project ID"
  type        = string

  default     = "lofty-memento-458508-i1" #change to your project id

  
  
}

variable "region" {
    description = "Region for the network"
    type        = string
    default     = "europe-central2"
}

variable "private_key_path" {
  type = string
  description = "Path to a private key"
}
