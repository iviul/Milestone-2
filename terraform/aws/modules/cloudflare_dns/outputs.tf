output "created_dns_records" {
  value = {
    for name, rec in cloudflare_dns_record.dns : name => rec.id
  }
}

