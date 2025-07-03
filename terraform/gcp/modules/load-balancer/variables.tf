variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west-3-a"
}

variable "network" {
  description = "VPC network self link"
  type        = string
}

variable "instances" {
  description = "List of instance self links"
  type        = list(string)
}

variable "load_balancers" {
  description = "List of load balancer configurations from config file"
  type = list(object({
    name               = string
    internal           = bool
    load_balancer_type = string
    vpc                = string
    protocol           = string
    port               = number
    target_type        = string
    security_groups    = list(string)
    subnets            = list(string)
    target_tags        = list(string)
  }))
}