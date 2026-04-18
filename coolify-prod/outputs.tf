locals {
  coolify_ui_url = "http://${module.control_plane.tailscale_hostname}:8000"
}

output "coolify_ui" {
  description = "Open over Tailscale after provisioning completes."
  value       = local.coolify_ui_url
}

output "control_plane" {
  description = "Control plane server details."
  value = {
    hetzner_id     = module.control_plane.id
    public_ipv4    = module.control_plane.public_ipv4
    private_ipv4   = module.control_plane.private_ipv4
    tailscale_name = module.control_plane.tailscale_hostname
  }
}

output "app_servers" {
  description = "App server details keyed by app_servers map key."
  value = {
    for k, m in module.app_server : k => {
      hetzner_id     = m.id
      public_ipv4    = m.public_ipv4
      private_ipv4   = m.private_ipv4
      tailscale_name = m.tailscale_hostname
    }
  }
}

output "app_base_fqdn" {
  description = "Primary Coolify app base domain."
  value       = "${var.app_subdomain}.${var.base_domain}"
}

output "app_wildcard_fqdn" {
  description = "Wildcard DNS covering preview deployments under app_base_fqdn."
  value       = "*.${var.app_subdomain}.${var.base_domain}"
}

output "primary_origin_ipv4" {
  description = "Public IPv4 currently serving DNS-managed hostnames."
  value       = module.app_server[var.primary_app_server_key].public_ipv4
}

output "coolify_management_ssh_private_key" {
  description = "Private key to paste into Coolify UI when registering app servers."
  value       = tls_private_key.coolify_management.private_key_openssh
  sensitive   = true
}
