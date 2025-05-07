variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnets" {
  type = list(object({
    name   = string
    cidr   = string
    public = bool
    zone   = string
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
    attach_to   = list(string)
    description = string
    ingress = list(object({
      protocol   = string
      port       = number
      source     = string
    }))
    egress = list(object({
      protocol    = string
      port        = number
      destination = string
    }))
  }))
  description = "Firewall definitions mapping tags → ingress/egress rules"
}
