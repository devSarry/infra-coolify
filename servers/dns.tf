module "cloudflare_zone" {
  source = "../modules/cloudflare-zone"

  domain      = "sarry.dev"
  origin_ipv4 = hcloud_server.coolify_server.ipv4_address

  subdomains = [
    "app",
    "api",
    "grafana",
    "coolify",
    "staging",
    "n8n",
  ]

  coolify_dashboard_subdomain = "coolify"
  admin_ip_allowlist          = [] # Add your admin IPs here

  rate_limit_general_rpm = 300
  rate_limit_auth_rpm    = 10

  redirect_www_to_apex = true
}
