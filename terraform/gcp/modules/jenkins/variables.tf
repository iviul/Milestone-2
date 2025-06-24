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

variable "jenkins_admin_username" {
  type        = string
  description = "Username for the Jenkins admin user"
}

variable "jenkins_admin_password" {
  type        = string
  description = "Password for the Jenkins admin user"
}

variable "jenkins_hostname" {
  type        = string
  description = "Hostname for the Jenkins service"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class to use for Jenkins"
  default     = "nginx"
}

variable "jenkins_tls_secret_name" {
  type        = string
  description = "Name of the TLS secret for Jenkins"
  default     = "nginx-hello-tls-secret"
}
