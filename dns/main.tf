

# Add a new “A” record, with the hostname “coolify**”, and the value is the IP address of your remote server, and click save.
resource "cloudflare_dns_record" "coolify_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "coolify"
  value   = hcloud_server.coolify_server.ipv4_address
  type    = "A"
  ttl     = 1
}