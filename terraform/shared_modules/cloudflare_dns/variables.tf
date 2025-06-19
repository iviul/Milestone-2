variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare"
  sensitive   = true
  default     = "aJLTlqyMHshCQ6EovdpjIQjDphJ2I308vI9Y2htU"
}

variable "dns_records_config" {
  description = "DNS records from config"
  type = list(object({
    name          = string
    type          = string
    proxied       = bool
    value         = string
    resolve_value = optional(bool)
  }))
}


variable "resource_dns_map" {
  description = "Map of resource names to DNS values"
  type        = map(string)
  default     = {}
}
