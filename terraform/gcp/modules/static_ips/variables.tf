variable "static_ips" {
  description = "List of static IPs to reserve"
  type = list(object({
    name   = string
    type   = string
    region = optional(string)
  }))
}