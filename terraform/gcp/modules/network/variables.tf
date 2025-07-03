variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}

variable "networks" {
  type = list(object({
    name      = string
    vpc_cidr  = string
    psa_range = string
    subnets = list(object({
      name   = string
      cidr   = string
      public = bool
      zone   = string
    }))
  }))
  description = "List of subnets with name, cidr, and whether public"
}

variable "acls" {
  type = list(object({
    name = string
    cidr = string
  }))
  description = "Named network ACLs for firewall source/dest lookup"
}

variable "security_groups" {
  type = list(object({
    name        = string
    vpc         = string
    attach_to   = list(string)
    description = string
    ingress = list(object({
      protocol = string
      port     = number
      source   = string
    }))
  }))
  description = "Firewall definitions mapping tags → ingress/egress rules"
}

variable "health_check_port" {
  description = "Port used for health checks (default: 6443 for K3s)"
  type        = number
  default     = 6443
}

