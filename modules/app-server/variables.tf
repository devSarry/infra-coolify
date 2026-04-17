variable "name" {
  description = "Server hostname."
  type        = string
}

variable "server_type" {
  description = "Hetzner server type."
  type        = string
}

variable "location" {
  description = "Hetzner location code."
  type        = string
}

variable "image" {
  description = "Hetzner image slug."
  type        = string
  default     = "ubuntu-24.04"
}

variable "network_id" {
  description = "ID of Hetzner private network."
  type        = string
}

variable "private_ip" {
  description = "Static private IP inside subnet."
  type        = string
}

variable "authorized_ssh_public_keys" {
  description = "SSH public keys installed into root authorized_keys."
  type        = list(string)
}

variable "tailscale_auth_key" {
  description = "One-shot Tailscale auth key."
  type        = string
  sensitive   = true
}

variable "tailscale_hostname" {
  description = "Tailscale hostname for this node."
  type        = string
}
