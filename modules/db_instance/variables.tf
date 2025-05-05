variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "database_version" {
  description = "The database version for the Cloud SQL instance"
  type        = string
  default     = "POSTGRES_15"
  
}

variable "tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
  
}

variable "instance_name" {
  description = "Name of the VPC"
  type        = string
  default     = "schedule"
  
}

variable "db_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "schedule_db"
  
}

variable "db_user" {
  description = "The username for the PostgreSQL database"
  type        = string
  default     = "db_user"
  
}

variable "db_password" {
  description = "The password for the PostgreSQL database user"
  type        = string
  default = "password"
  
}

variable "region" {
  description = "The region for the Cloud SQL instance"
  type        = string
  default     = "europe-central2"
}

variable "deletion_protection" {
  description = "Enable deletion protection for the Cloud SQL instance"
  type        = bool
  default     = false
  
}

variable "private_network" {
  description = "The private network for the Cloud SQL instance"
  type        = string
}
