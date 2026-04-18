output "id" {
  description = "Hetzner server ID."
  value       = hcloud_server.this.id
}

output "public_ipv4" {
  description = "Public IPv4 of app server."
  value       = hcloud_server.this.ipv4_address
}

output "private_ipv4" {
  description = "Private IPv4 of app server."
  value       = var.private_ip
}

output "tailscale_hostname" {
  description = "Tailscale hostname of app server."
  value       = var.tailscale_hostname
}
