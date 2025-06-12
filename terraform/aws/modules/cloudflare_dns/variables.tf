variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
}

variable "dns_records_config" {
  description = "DNS records from config"
  type = list(object({
    name       = string
    type       = string
    proxied    = bool
    value      = optional(string)
    value_from = optional(string)
    lb_name    = optional(string)
  }))
}

variable "lb_dns_names" {
}
