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

# variable "swap_usage_threshold" {
#   description = "Swap usage threshold in percentage"
#   type        = number

# }

# variable "processes_threshold" {
#   description = "Processes count threshold"
#   type        = number

# }

variable "agent_self_threshold" {
  description = "Agent self metric threshold (example: CPU usage %)"
  type        = number

}

variable "gpu_usage_threshold" {
  description = "GPU usage threshold in percentage"
  type        = number

}

variable "network_interface_usage_threshold" {
  description = "Network interface usage threshold in bytes"
  type        = number
}
