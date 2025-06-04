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
    name     = string
    vpc_cidr = string
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
    egress = list(object({
      protocol    = string
      port        = number
      destination = string
    }))
  }))
  description = "Firewall definitions mapping tags → ingress/egress rules"
}

variable "load_balancer_forwarding_rule_ip" {
  description = "The forwarding rule IP from the load balancer module."
  type        = string
}
