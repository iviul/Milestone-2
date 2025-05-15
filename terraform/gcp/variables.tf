variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "ace-thought-458516-d9"
  
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
