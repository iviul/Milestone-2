variable "alert_email" {
  description = "Email for sending monitoring alerts"
  type        = string
}

variable "disk_usage_threshold" {
  description = "Disk usage threshold in percentage"
  type        = number

}

variable "memory_usage_threshold" {
  description = "Memory usage threshold in percentage"
  type        = number

}

variable "network_outbound_threshold" {
  description = "Network outbound threshold in bytes"
  type        = number

}

variable "cpu_usage_threshold" {
  description = "CPU usage threshold in percentage"
  type        = number

}

