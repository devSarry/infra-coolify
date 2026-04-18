# www → apex redirect via Ruleset engine
resource "cloudflare_ruleset" "redirects" {
  count = var.manage_redirects && var.redirect_www_to_apex ? 1 : 0

  zone_id = data.cloudflare_zone.this.zone_id
  name    = "Redirect www to apex"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    action      = "redirect"
    expression  = "(http.host eq \"www.${var.domain}\")"
    description = "Redirect www.${var.domain} to ${var.domain}"
    enabled     = true
    ref         = "www-to-apex"

    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://${var.domain}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}
