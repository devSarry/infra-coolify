# WAF Custom Rules - IP allowlisting via Ruleset engine
resource "cloudflare_ruleset" "waf_custom" {
  count = var.manage_waf ? 1 : 0

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "Coolify WAF Rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = concat(
    # Rule 1: Block non-admin IPs from Coolify dashboard
    var.coolify_dashboard_subdomain != "" && length(var.admin_ip_allowlist) > 0 ? [{
      action      = "block"
      expression  = "(http.host eq \"${var.coolify_dashboard_subdomain}.${var.domain}\" and not ip.src in {${join(" ", var.admin_ip_allowlist)}})"
      description = "Block non-admin IPs from Coolify dashboard"
      enabled     = true
      ref         = "dashboard-allowlist"
    }] : [],

    # Rule 2: Stricter rate limit for auth endpoints
    [{
      action      = "block"
      expression  = "((http.host eq \"${var.domain}\" or http.host contains \".${var.domain}\") and (http.request.uri.path contains \"/login\" or http.request.uri.path contains \"/auth\" or http.request.uri.path contains \"/api/auth\" or http.request.uri.path contains \"/register\" or http.request.uri.path contains \"/reset-password\"))"
      description = "Rate limit auth endpoints (${var.rate_limit_auth_rpm} rpm)"
      enabled     = true
      ref         = "rate-limit-auth"

      ratelimit = {
        characteristics     = ["ip.src", "http.request.uri.path"]
        period              = 60
        requests_per_period = var.rate_limit_auth_rpm
      }
    }],

    # Rule 3: General rate limit - challenge excessive requests
    [{
      action      = "managed_challenge"
      expression  = "(http.host eq \"${var.domain}\" or http.host contains \".${var.domain}\")"
      description = "General rate limit (${var.rate_limit_general_rpm} rpm)"
      enabled     = true
      ref         = "rate-limit-general"

      ratelimit = {
        characteristics     = ["ip.src"]
        period              = 60
        requests_per_period = var.rate_limit_general_rpm
      }
    }]
  )
}
