variable "tailscale_tailnet" {
  description = "Tailscale tailnet identifier."
  type        = string
}

variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth client ID with auth_keys scope."
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth client secret."
  type        = string
  sensitive   = true
}

variable "instance_name" {
  description = "Short deployment name used in resource names."
  type        = string
  default     = "prod"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.instance_name))
    error_message = "instance_name must start with lowercase letter and contain only lowercase alphanumerics or hyphens."
  }
}

variable "base_domain" {
  description = "Cloudflare-managed apex domain for this Coolify deployment."
  type        = string
  default     = "sarry.dev"
}

variable "app_subdomain" {
  description = "Primary Coolify app base subdomain."
  type        = string
  default     = "apps"
}

variable "location" {
  description = "Hetzner location code."
  type        = string
  default     = "hel1"
}

variable "image" {
  description = "Hetzner image slug."
  type        = string
  default     = "ubuntu-24.04"
}

variable "app_servers" {
  description = "Map of app servers to create."
  type = map(object({
    server_type = string
    private_ip  = string
  }))
  default = {
    "app-1" = {
      server_type = "cx23"
      private_ip  = "192.168.1.20"
    }
  }
}

variable "primary_app_server_key" {
  description = "App server key used as DNS origin target."
  type        = string
  default     = "app-1"

  validation {
    condition     = contains(keys(var.app_servers), var.primary_app_server_key)
    error_message = "primary_app_server_key must match one key in app_servers."
  }
}

variable "operator_ssh_public_keys" {
  description = "Break-glass SSH public keys installed on servers."
  type        = list(string)
  default     = []
}

variable "tailscale_tag" {
  description = "Existing Tailscale ACL tag used for bootstrap auth keys."
  type        = string
  default     = "tag:coolify-prod"

  validation {
    condition     = can(regex("^tag:[a-z0-9-]+$", var.tailscale_tag))
    error_message = "tailscale_tag must look like tag:coolify-prod."
  }
}
