variable "domain" {
  description = "The root domain (e.g., example.com)"
  type        = string
}

variable "origin_ipv4" {
  description = "The IPv4 address of the origin server (Hetzner)"
  type        = string
}

variable "subdomains" {
  description = "List of subdomains to create A records and wildcards for"
  type        = list(string)
  default     = []
}

variable "coolify_dashboard_subdomain" {
  description = "Subdomain hosting the Coolify dashboard to protect with IP allowlist"
  type        = string
  default     = ""
}

variable "admin_ip_allowlist" {
  description = "List of IPs/CIDRs allowed to access the Coolify dashboard"
  type        = list(string)
  default     = []
}

variable "rate_limit_general_rpm" {
  description = "General rate limit in requests per minute"
  type        = number
  default     = 300
}

variable "rate_limit_auth_rpm" {
  description = "Rate limit for auth endpoints in requests per minute"
  type        = number
  default     = 10
}

variable "redirect_www_to_apex" {
  description = "Redirect www.domain.com to domain.com"
  type        = bool
  default     = false
}

variable "proxied" {
  description = "Enable Cloudflare proxy (orange cloud) for DNS records"
  type        = bool
  default     = true
}

variable "ttl" {
  description = "DNS TTL in seconds (1 = automatic)"
  type        = number
  default     = 1
}
