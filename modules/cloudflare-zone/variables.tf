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
