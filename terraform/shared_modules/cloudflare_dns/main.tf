terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}


locals {
  records = [
    for record in var.dns_records_config : {
      name = record.name
      type = record.type
      value = (
        lookup(record, "resolve_value", false) ?
        lookup(var.resource_dns_map, record.value, record.value) :
        record.value
      )
      proxied = lookup(record, "proxied", true)
      ttl     = lookup(record, "ttl", 1)
    }
  ]
}

resource "cloudflare_dns_record" "dns" {
  for_each = {
    for rec in local.records : rec.name => rec
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = each.value.proxied
}

