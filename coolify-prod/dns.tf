module "cloudflare_zone" {
  source = "../modules/cloudflare-zone"

  domain      = var.base_domain
  origin_ipv4 = module.app_server[var.primary_app_server_key].public_ipv4

  subdomains = distinct(concat(
    [var.app_subdomain],
    ["cue"],
  ))

  proxied = false
  ttl     = 60
}
