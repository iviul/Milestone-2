variable "project_id" {
  description = "The GCP project ID"
  type        = string
  
  
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
