
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
  ttl = 1
  proxied = true
}

# Create wildcard DNS record for sarry.dev
resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "*"
  content = hcloud_server.coolify_server.ipv4_address
  type = "A"
  ttl = 1
  proxied = true
}

# Redirect www to non-www
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "www"
  content = "sarry.dev"
  type = "CNAME"
  ttl = 1
  proxied = true
}


# Create coolify.sarry.dev DNS record
resource "cloudflare_record" "coolify" {
  zone_id = data.cloudflare_zone.sarry_dev_full_zone.id
  name = "coolify"
  content = hcloud_server.coolify_server.ipv4_address
  type = "A"
  ttl = 1
  proxied = true
}


resource "cloudflare_ruleset" "redirect-www-wildcard-to-non-www" {
  zone_id     = data.cloudflare_zone.sarry_dev_full_zone.id
  name        = "redirects"
  description = "Redirect www subdomains to non-www"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 302
        target_url {
          expression = "wildcard_replace(http.request.full_uri, \"https://www.*\", \"https://${1}\")"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.request.full_uri wildcard \"https://www.*\")"
    description = "Redirect www subdomains to non-www"
    enabled     = true
  }
}
