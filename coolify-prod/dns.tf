module "cloudflare_zone" {
  source = "../modules/cloudflare-zone"

  domain      = var.base_domain
  origin_ipv4 = module.app_server[var.primary_app_server_key].public_ipv4

  subdomains = distinct(concat(
    [var.app_subdomain],
    ["cue"],
  ))

  coolify_dashboard_subdomain = "coolify"
  manage_redirects            = false
  manage_waf                  = false
  admin_ip_allowlist          = []

  rate_limit_general_rpm = 300
  rate_limit_auth_rpm    = 10

  redirect_www_to_apex = true
  proxied              = false
  ttl                  = 1
}
