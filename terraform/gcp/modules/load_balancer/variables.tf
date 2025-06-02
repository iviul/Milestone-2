variable "load_balancer_name" {
  description = "Base name used for all load balancer-related resources"
  type        = string
}

variable "region" {
  description = "Region where resources will be created (e.g., us-central1)"
  type        = string
}

variable "zone" {
  description = "Zone where the unmanaged instance group will be created (e.g., us-central1-a)"
  type        = string
}

variable "instances" {
  description = "List of instance self_links to include in the unmanaged instance group"
  type        = list(string)
}

variable "ip_address" {
  description = "Optional static IP address for the load balancer. Leave blank to create a new one."
  type        = string
  default     = ""
}

variable "load_balancer_port_range" {
  description = "Port or port range for the forwarding rule (e.g., '80' or '6443-6450')"
  type        = string

  validation {
    condition     = can(regex("^\\d+(-\\d+)?$", var.load_balancer_port_range))
    error_message = "Must be a valid port or port range like '80' or '6443-6450'."
  }
}

variable "health_check_port" {
  description = "Port used for health checks (default: 6443 for K3s)"
  type        = number
  default     = 6443
}

variable "network" {
  description = "The self_link of the VPC network where the instances and instance group reside"
  type        = string
}

