data "cloudflare_zone" "this" {
  filter = {
    name = var.domain
  }
}

# Root A record (@)
resource "cloudflare_dns_record" "root" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "@"
  content = var.origin_ipv4
  type    = "A"
  ttl     = var.ttl
  proxied = var.proxied
}

# Root wildcard (*.domain.com)
resource "cloudflare_dns_record" "root_wildcard" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "*"
  content = var.origin_ipv4
  type    = "A"
  ttl     = var.ttl
  proxied = var.proxied
}

# Subdomain A records (subdomain.domain.com)
resource "cloudflare_dns_record" "subdomain" {
  for_each = toset(var.subdomains)

  zone_id = data.cloudflare_zone.this.zone_id
  name    = each.value
  content = var.origin_ipv4
  type    = "A"
  ttl     = var.ttl
  proxied = var.proxied
}

# Subdomain wildcards for preview deployments (*.subdomain.domain.com)
# Per Coolify docs: preview URLs use {{pr_id}}.{{domain}}
# With domain = app.example.com, previews become 123.app.example.com
resource "cloudflare_dns_record" "subdomain_wildcard" {
  for_each = toset(var.subdomains)

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "*.${each.value}"
  content = var.origin_ipv4
  type    = "A"
  ttl     = var.ttl
  proxied = var.proxied
}
