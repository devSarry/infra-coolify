output "network_id" {
  description = "ID of Hetzner network."
  value       = hcloud_network.this.id
}

output "subnet_ip_range" {
  description = "CIDR of created subnet."
  value       = hcloud_network_subnet.this.ip_range
}
