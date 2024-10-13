
data "cloudflare_zone" "sarry_dev_full_zone" {
  name = "sarry.dev"
}

# Root DNS record
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name    = "@"
  content = hcloud_server.coolify_server.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

# Wildcard DNS record
resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name    = "*"
  content = hcloud_server.coolify_server.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

# CNAME for www.*.sarry.dev
resource "cloudflare_record" "www_wildcard" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name    = "www.*"
  content = "@"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# CNAME for www to root
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name    = "www"
  content = "sarry.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# Page rule for www.sarry.dev
resource "cloudflare_page_rule" "sarry_dev" {
  zone_id  = data.cloudflare_zone.sarry_dev_full_zone.id
  target   = "www.sarry.dev/*"
  priority = 1
  actions {
    forwarding_url {
      url         = "https://sarry.dev/$1"
      status_code = 301
    }
  }
}

# Page rule for www.*.sarry.dev
resource "cloudflare_page_rule" "wildcard_subdomain_redirect" {
  zone_id  = data.cloudflare_zone.sarry_dev_full_zone.id
  target   = "www.*.sarry.dev/*"
  priority = 2
  actions {
    forwarding_url {
      url         = "https://$1.sarry.dev/$2"
      status_code = 301
    }
  }
}

# Coolify DNS record
resource "cloudflare_record" "coolify" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name    = "coolify"
  content = hcloud_server.coolify_server.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}
