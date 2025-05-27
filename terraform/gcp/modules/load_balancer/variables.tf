variable "load_balancer_name" {
  type = string
}

variable "region" {
  type = string
}

variable "instances" {
  type = list(string)
}

variable "ip_address" {
  type = string
  default = ""
}

variable "load_balancer_port_range" {
  type = string
}

variable "health_check_port" {
  type    = number
  default = 6443
}
