
data "cloudflare_zone" "sarry_dev_full_zone" {
    name = "sarry.dev"
}


# Create @ DNS record for sarry.dev
# The @ symbol is a placeholder
# for the root domain
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "@"
  content = hcloud_server.coolify_server.ipv4_address
  type = "A"
  ttl = 3600
}

# Create wildcard DNS record for sarry.dev
resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "*"
  content = hcloud_server.coolify_server.ipv4_address
  type = "A"
  ttl = 3600
}

# Redirect www to non-www
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "www"
  content = "sarry.dev"
  type = "CNAME"
  ttl = 3600
}

resource "cloudflare_page_rule" "sarry_dev" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  target = "www.sarry.dev/*"
  priority = 1
  actions {
    forwarding_url {
      url         = "https://sarry.dev/$1"
      status_code = 301
    }
  }
}

# Create coolify.sarry.dev DNS record
resource "cloudflare_record" "coolify" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "coolify"
  content = hcloud_server.coolify_server.ipv4_address
  type = "A"
  ttl = 3600
}

