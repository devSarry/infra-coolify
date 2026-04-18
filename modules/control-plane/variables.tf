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

variable "ssh_public_key_openssh" {
  description = "Public half of Coolify management key."
  type        = string
}

variable "ssh_private_key_openssh" {
  description = "Private half of Coolify management key."
  type        = string
  sensitive   = true
}

variable "tailscale_auth_key" {
  description = "One-shot tagged Tailscale auth key."
  type        = string
  sensitive   = true
}

variable "tailscale_hostname" {
  description = "Tailscale hostname for this node."
  type        = string
}

variable "coolify_version" {
  description = "Coolify version to install."
  type        = string
  default     = "latest"
}

variable "data_volume_size" {
  description = "Data volume size in GB."
  type        = number
  default     = 20
}

variable "operator_ssh_public_keys" {
  description = "Extra SSH public keys for break-glass access."
  type        = list(string)
  default     = []
}
