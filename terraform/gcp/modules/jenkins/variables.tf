variable "cluster_endpoint" {
  type = string
}

variable "ca_certificate" {
  type = string
}

variable "access_token" {
  type = string
}

variable "jenkins_namespace" {
  type    = string
  default = "jenkins"
}

variable "admin_user" {
  type    = string
  default = "admin"
}

variable "admin_password" {
  type    = string
  default = "admin"
}
