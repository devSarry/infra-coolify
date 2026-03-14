output "zone_id" {
  description = "The Cloudflare zone ID"
  value       = data.cloudflare_zone.this.zone_id
}

output "zone_name" {
  description = "The Cloudflare zone name"
  value       = data.cloudflare_zone.this.name
}

output "root_record_id" {
  description = "The ID of the root A record"
  value       = cloudflare_dns_record.root.id
}

output "subdomain_records" {
  description = "Map of subdomain A record IDs"
  value       = { for k, v in cloudflare_dns_record.subdomain : k => v.id }
}

output "subdomain_wildcard_records" {
  description = "Map of subdomain wildcard A record IDs"
  value       = { for k, v in cloudflare_dns_record.subdomain_wildcard : k => v.id }
}
